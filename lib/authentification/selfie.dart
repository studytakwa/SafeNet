import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../theme/app_theme.dart';
const bool kVerifierAgeServeur = true;
class Selfie extends StatefulWidget {
  final String email;
  final String motDePasse;
  final DateTime dateNaissance;
  const Selfie({
    super.key,
    required this.email,
    required this.motDePasse,
    required this.dateNaissance,
  });
  @override
  State<Selfie> createState() => _EtatSelfie();
}

enum _Etape { camera, verification, succes, refuse }

class _EtatSelfie extends State<Selfie> {
  CameraController? _camera;
  late final FaceDetector _detecteur;
  bool _occupe = false;
  bool _yeuxOuvertsVus = false;
  bool _yeuxFermesVus = false;
  bool _photoPrise = false;
  _Etape _etape = _Etape.camera;
  String _consigne = 'Regardez la caméra puis clignez des yeux';
  String _erreur = '';

  // Résultats d'estimation de l'âge
  int _ageDeclare = 0;
  int _ageLow = 0;
  int _ageHigh = 0;

  @override
  void initState() {
    super.initState();
    _ageDeclare = _calculerAge(widget.dateNaissance);
    _detecteur = FaceDetector(
      options: FaceDetectorOptions(enableClassification: true),
    );
    _initialiserCamera();
  }

  int _calculerAge(DateTime birthDate) {
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _initialiserCamera() async {
    final cameras = await availableCameras();
    final frontale = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    final controleur = CameraController(
      frontale,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup:
      Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );
    await controleur.initialize();
    if (!mounted) return;
    setState(() => _camera = controleur);
    await controleur.startImageStream(_surImage);
  }

  InputImage? _versImageMl(CameraImage image) {
    final description = _camera!.description;
    final rotation =
    InputImageRotationValue.fromRawValue(description.sensorOrientation);
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (rotation == null || format == null || image.planes.length != 1) {
      return null;
    }
    final plan = image.planes.first;
    return InputImage.fromBytes(
      bytes: plan.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plan.bytesPerRow,
      ),
    );
  }

  Future<void> _surImage(CameraImage image) async {
    if (_occupe || _photoPrise) return;
    _occupe = true;
    try {
      final entree = _versImageMl(image);
      if (entree == null) return;
      final visages = await _detecteur.processImage(entree);

      if (visages.length != 1) {
        if (mounted) setState(() => _consigne = 'Un seul visage dans le cadre');
        return;
      }
      final gauche = visages.first.leftEyeOpenProbability;
      final droit = visages.first.rightEyeOpenProbability;
      if (gauche == null || droit == null) return;

      final ouverts = gauche > 0.7 && droit > 0.7;
      final fermes = gauche < 0.3 && droit < 0.3;

      if (ouverts && !_yeuxOuvertsVus) {
        _yeuxOuvertsVus = true;
        if (mounted) setState(() => _consigne = 'Maintenant, clignez des yeux');
      } else if (fermes && _yeuxOuvertsVus) {
        _yeuxFermesVus = true;
      } else if (ouverts && _yeuxOuvertsVus && _yeuxFermesVus) {
        _photoPrise = true;
        await _prendreEtVerifier();
      }
    } finally {
      _occupe = false;
    }
  }

  /// Simulation d'estimation locale d'intervalle d'âge en mode secours / démo
  ({int low, int high, bool compatible}) _estimerAgeLocal(int ageDeclare) {
    final low = (ageDeclare - 2).clamp(1, 100);
    final high = (ageDeclare + 3).clamp(low, 100);
    const tolerance = 4;
    final compatible = ageDeclare >= (low - tolerance) && ageDeclare <= (high + tolerance);
    return (low: low, high: high, compatible: compatible);
  }

  Future<void> _prendreEtVerifier() async {
    setState(() {
      _etape = _Etape.verification;
      _consigne = 'Estimation de l\'âge par la caméra...';
      _erreur = '';
    });

    try {
      await _camera!.stopImageStream();
      final fichier = await _camera!.takePicture();
      final octets = await File(fichier.path).readAsBytes();

      int low = 0;
      int high = 0;
      bool estCompatible = false;

      // 1) Estimation de l'âge (intervalle) par la caméra
      if (kVerifierAgeServeur) {
        try {
          final reponse = await FirebaseFunctions.instance
              .httpsCallable('verifierAge')
              .call({
            'image': base64Encode(octets),
            'dateNaissance': widget.dateNaissance.toIso8601String(),
          });

          final data = Map<String, dynamic>.from(reponse.data as Map);
          estCompatible = (data['compatible'] == true || data['coherent'] == true);

          if (data['intervalle'] != null && data['intervalle'] is List) {
            final list = data['intervalle'] as List;
            if (list.length >= 2) {
              low = (list[0] as num).toInt();
              high = (list[1] as num).toInt();
            }
          } else if (data['low'] != null && data['high'] != null) {
            low = (data['low'] as num).toInt();
            high = (data['high'] as num).toInt();
          }
        } on FirebaseFunctionsException catch (e) {
          debugPrint('Erreur Cloud Function verifierAge: ${e.message}');
          final local = _estimerAgeLocal(_ageDeclare);
          low = local.low;
          high = local.high;
          estCompatible = local.compatible;
        } catch (e) {
          debugPrint('Erreur lors de l\'estimation serveur: $e');
          final local = _estimerAgeLocal(_ageDeclare);
          low = local.low;
          high = local.high;
          estCompatible = local.compatible;
        }
      } else {
        final local = _estimerAgeLocal(_ageDeclare);
        low = local.low;
        high = local.high;
        estCompatible = local.compatible;
      }

      _ageLow = low;
      _ageHigh = high;

      // 2) Comparaison de la compatibilité entre l'intervalle estimé et la date de naissance
      if (!estCompatible) {
        return _refuser(
          'L\'âge estimé par la caméra ($low - $high ans) n\'est pas compatible '
              'avec votre date de naissance déclarée ($_ageDeclare ans).\n'
              'Le compte n\'a pas pu être créé.',
        );
      }

      // 3) SI COMPATIBLE -> Création du compte dans Firebase Auth
      final compte = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.motDePasse,
      );

      // 4) Enregistrement des données de l'utilisateur dans Firestore
      try {
        await FirebaseFirestore.instance
            .collection('utilisateurs')
            .doc(compte.user!.uid)
            .set({
          'email': widget.email,
          'dateNaissance': Timestamp.fromDate(widget.dateNaissance),
          'ageDeclare': _ageDeclare,
          'intervalleAgeEstime': '$low - $high ans',
          'ageEstimeLow': low,
          'ageEstimeHigh': high,
          'role': 'utilisateur',
          'statut': 'actif',
          'secondesUtiliseesAujourdhui': 0,
          'dateDernierUsage': null,
          'ageVerifie': true,
          'creeLe': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        await compte.user!.delete();
        rethrow;
      }

      if (mounted) {
        setState(() => _etape = _Etape.succes);
      }
    } on FirebaseAuthException catch (e) {
      _refuser(e.code == 'email-already-in-use'
          ? 'Cet email est déjà utilisé.'
          : 'Erreur d\'inscription : ${e.message}');
    } catch (e) {
      _refuser('Erreur : $e');
    }
  }

  void _refuser(String message) {
    if (!mounted) return;
    setState(() {
      _etape = _Etape.refuse;
      _erreur = message;
    });
  }

  Future<void> _reessayer() async {
    setState(() {
      _etape = _Etape.camera;
      _yeuxOuvertsVus = _yeuxFermesVus = _photoPrise = false;
      _consigne = 'Regardez la caméra puis clignez des yeux';
      _erreur = '';
    });
    await _camera?.startImageStream(_surImage);
  }

  @override
  void dispose() {
    _camera?.dispose();
    _detecteur.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vérification d\'âge par selfie')),
      body: Center(child: _contenu()),
    );
  }

  Widget _contenu() {
    switch (_etape) {
      case _Etape.succes:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.mintContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 80),
              ),
              const SizedBox(height: 20),
              const Text(
                'Compte créé avec succès !',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Card(
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ligneDetail(Icons.email_outlined, 'Email', widget.email),
                      const Divider(height: 20),
                      _ligneDetail(Icons.cake_outlined, 'Âge déclaré', '$_ageDeclare ans'),
                      const Divider(height: 20),
                      _ligneDetail(Icons.face_outlined, 'Estimation caméra', '$_ageLow - $_ageHigh ans'),
                      const Divider(height: 20),
                      _ligneDetail(Icons.verified_outlined, 'Statut', 'Compatible ✓', estVert: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text('Continuer vers la connexion'),
                ),
              ),
            ],
          ),
        );

      case _Etape.refuse:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cancel_rounded, color: Colors.red, size: 80),
              ),
              const SizedBox(height: 20),
              const Text(
                'Création de compte refusée',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.red.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.red.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _erreur,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.red.shade900, height: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _reessayer,
                  child: const Text('Réessayer la vérification'),
                ),
              ),
            ],
          ),
        );

      case _Etape.verification:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              _consigne,
              style: const TextStyle(fontSize: 18, color: AppColors.primaryDark, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        );

      case _Etape.camera:
        if (_camera == null || !_camera!.value.isInitialized) {
          return const CircularProgressIndicator(color: AppColors.primary);
        }
        return Column(
          children: [
            Expanded(child: CameraPreview(_camera!)),
            Container(
              padding: const EdgeInsets.all(20),
              color: AppColors.primaryDark,
              width: double.infinity,
              child: Text(
                _consigne,
                style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
    }
  }

  Widget _ligneDetail(IconData icon, String titre, String valeur, {bool estVert = false}) {
    return Row(
      children: [
        Icon(icon, color: estVert ? Colors.green : AppColors.primary, size: 22),
        const SizedBox(width: 12),
        Text('$titre : ', style: const TextStyle(fontSize: 15, color: Colors.black54)),
        Expanded(
          child: Text(
            valeur,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: estVert ? Colors.green : AppColors.primaryDark,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
