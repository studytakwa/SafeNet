import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// false = mode démo (pas d'estimation d'âge). true = appelle la Cloud Function.
const bool kVerifierAgeServeur = false;

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

  @override
  void initState() {
    super.initState();
    _detecteur = FaceDetector(
      options: FaceDetectorOptions(enableClassification: true),
    );
    _initialiserCamera();
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

  Future<void> _prendreEtVerifier() async {
    setState(() {
      _etape = _Etape.verification;
      _consigne = 'Vérification en cours...';
    });
    try {
      await _camera!.stopImageStream();
      final fichier = await _camera!.takePicture();
      final octets = await File(fichier.path).readAsBytes();

      // 1) Vérification de l'âge par le visage
      if (kVerifierAgeServeur) {
        final reponse = await FirebaseFunctions.instance
            .httpsCallable('verifierAge')
            .call({
          'image': base64Encode(octets),
          'dateNaissance': widget.dateNaissance.toIso8601String(),
        });
        if (reponse.data['compatible'] != true) {
          return _refuser('Âge non compatible avec la date déclarée.');
        }
      }

      // 2) Création du compte (seulement si tout est bon)
      final compte = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.motDePasse,
      );
      try {
        await FirebaseFirestore.instance
            .collection('utilisateurs')
            .doc(compte.user!.uid)
            .set({
          'email': widget.email,
          'dateNaissance': Timestamp.fromDate(widget.dateNaissance),
          'role': 'utilisateur',
          'statut': 'actif',
          'secondesUtiliseesAujourdhui': 0,
          'dateDernierUsage': null,
          'ageVerifie': kVerifierAgeServeur,
          'creeLe': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        await compte.user!.delete(); // on ne garde pas un compte incomplet
        rethrow;
      }

      if (mounted) setState(() => _etape = _Etape.succes);
    } on FirebaseAuthException catch (e) {
      _refuser(e.code == 'email-already-in-use'
          ? 'Cet email est déjà utilisé.'
          : 'Erreur : ${e.message}');
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
    });
    await _camera!.startImageStream(_surImage);
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
      appBar: AppBar(title: const Text('Vérification par selfie')),
      body: Center(child: _contenu()),
    );
  }

  Widget _contenu() {
    switch (_etape) {
      case _Etape.succes:
        return Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 90),
          const SizedBox(height: 16),
          const Text('Compte créé avec succès', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('Continuer'),
          ),
        ]);
      case _Etape.refuse:
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cancel, color: Colors.red, size: 90),
            const SizedBox(height: 16),
            const Text('Inscription refusée', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text(_erreur, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(onPressed: _reessayer, child: const Text('Réessayer')),
          ]),
        );
      case _Etape.verification:
        return Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(_consigne),
        ]);
      case _Etape.camera:
        if (_camera == null || !_camera!.value.isInitialized) {
          return const CircularProgressIndicator();
        }
        return Column(children: [
          Expanded(child: CameraPreview(_camera!)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(_consigne,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center),
          ),
        ]);
    }
  }
}