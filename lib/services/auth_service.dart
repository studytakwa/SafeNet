import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/utilisateur_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> seConnecter({
    required String email,
    required String motDePasse,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: motDePasse,
    );
  }

  Future<UserCredential> inscrireUtilisateur({
    required String email,
    required String motDePasse,
    required DateTime dateNaissance,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: motDePasse,
    );

    final nouvelUtilisateur = UtilisateurModel(
      uid: cred.user!.uid,
      email: email.trim(),
      dateNaissance: dateNaissance,
    );

    await _firestore
        .collection('utilisateurs')
        .doc(cred.user!.uid)
        .set(nouvelUtilisateur.toMap());

    return cred;
  }

  Future<void> seDeconnecter() async {
    await _auth.signOut();
  }

  Future<UtilisateurModel?> recupererProfil(String uid) async {
    final doc = await _firestore.collection('utilisateurs').doc(uid).get();
    if (doc.exists) {
      return UtilisateurModel.fromFirestore(doc);
    }
    return null;
  }

  Future<bool> isUserBlocked(String uid) async {
    try {
      final doc = await _firestore.collection('profils').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if ((data?['bloque'] as bool?) ?? (data?['blocked'] as bool?) ?? false) {
          return true;
        }
      }
      final utilDoc = await _firestore.collection('utilisateurs').doc(uid).get();
      if (utilDoc.exists) {
        final data = utilDoc.data();
        if ((data?['bloque'] as bool?) ?? (data?['blocked'] as bool?) ?? false) {
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
