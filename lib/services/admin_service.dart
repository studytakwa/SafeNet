import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/admin_models.dart';
import '../models/post_model.dart';
class AdminService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? get utilisateurCourant => _auth.currentUser;
  String get uid => _auth.currentUser?.uid ?? '';
  // ───────────── Authentification ─────────────
  Future<void> connecter(String email, String motDePasse) =>
      _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: motDePasse,
      );
  Future<void> deconnecter() => _auth.signOut();
  Future<bool> aRoleAdmin(String userId) async {
    if (userId.isEmpty) return false;
    try {
      final d = await _db.collection('admins').doc(userId).get();
      if (!d.exists) return false;
      final role = '${d.data()?['role'] ?? ''}'.trim().toLowerCase();
      return role == 'admin';
    } catch (_) {
      return false;
    }
  }

  Stream<bool> roleAdmin() => _db
      .collection('admins')
      .doc(uid)
      .snapshots()
      .map((s) => s.exists && s.data()?['role'] == 'admin');

  String messageAuth(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'Adresse e-mail invalide.';
        case 'user-disabled':
          return 'Ce compte a été désactivé.';
        case 'user-not-found':
          return 'Aucun utilisateur trouvé avec cet e-mail dans Firebase Auth.';
        case 'wrong-password':
          return 'Mot de passe incorrect.';
        case 'invalid-credential':
          return 'E-mail ou mot de passe incorrect. Vérifiez le mot de passe créé dans Firebase Console.';
        case 'too-many-requests':
          return 'Trop de tentatives. Réessayez dans quelques minutes.';
        case 'network-request-failed':
          return 'Problème de connexion internet.';
        default:
          return 'Erreur Firebase (${e.code}): ${e.message}';
      }
    }
    return 'Erreur de connexion : $e';
  }

  // ───────────── Statistiques ─────────────

  Future<int> _compter(Query<Map<String, dynamic>> q) async =>
      (await q.count().get()).count ?? 0;

  Future<AdminStats> statistiques() async {
    final posts = _db.collection('posts');
    final r = await Future.wait([
      _compter(_db.collection(kCollectionProfils)),
      _compter(posts.where('status', isEqualTo: 'pending')),
      _compter(posts.where('status', isEqualTo: 'approved')),
      _compter(posts.where('status', isEqualTo: 'rejected')),
    ]);
    return AdminStats(
      utilisateurs: r[0],
      enAttente: r[1],
      acceptees: r[2],
      refusees: r[3],
    );
  }

  // ───────────── Utilisateurs (lecture seule) ─────────────

  Stream<List<AdminUser>> utilisateurs() =>
      _db.collection(kCollectionProfils).snapshots().map((s) {
        final l = s.docs.map(AdminUser.fromDoc).toList();
        l.sort((a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()));
        return l;
      });

  Stream<List<PostModel>> publicationsUtilisateur(String userId) => _db
      .collection('posts')
      .where('authorId', isEqualTo: userId)
      .snapshots()
      .map((s) {
    final l = s.docs.map(PostModel.fromDoc).toList();
    l.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return l;
  });

  /// Bloque un utilisateur (empêche la connexion et l'accès à l'application).
  Future<void> bloquerUtilisateur(String userId, {String? motif}) {
    final batch = _db.batch();
    batch.set(_db.collection('profils').doc(userId), {
      'bloque': true,
      'motifBlocage': motif,
      'bloqueLe': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    batch.set(_db.collection('utilisateurs').doc(userId), {
      'bloque': true,
      'motifBlocage': motif,
      'bloqueLe': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return batch.commit();
  }

  /// Débloque un utilisateur.
  Future<void> debloquerUtilisateur(String userId) {
    final batch = _db.batch();
    batch.set(_db.collection('profils').doc(userId), {
      'bloque': false,
      'motifBlocage': FieldValue.delete(),
      'bloqueLe': FieldValue.delete(),
    }, SetOptions(merge: true));
    batch.set(_db.collection('utilisateurs').doc(userId), {
      'bloque': false,
      'motifBlocage': FieldValue.delete(),
      'bloqueLe': FieldValue.delete(),
    }, SetOptions(merge: true));
    return batch.commit();
  }

  /// Supprime définitivement l'utilisateur de Firebase Auth (via Cloud Function) et de Firestore (profil, utilisateurs, posts).
  Future<void> supprimerCompteUtilisateur(String userId) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('deleteUser');
      await callable.call({'uid': userId});
    } catch (_) {}

    final postsQuery = await _db.collection('posts').where('authorId', isEqualTo: userId).get();
    final batch = _db.batch();
    
    for (final postDoc in postsQuery.docs) {
      final commentsQuery = await postDoc.reference.collection('comments').get();
      for (final commentDoc in commentsQuery.docs) {
        batch.delete(commentDoc.reference);
      }
      batch.delete(postDoc.reference);
    }

    batch.delete(_db.collection('profils').doc(userId));
    batch.delete(_db.collection('utilisateurs').doc(userId));

    await batch.commit();
  }

  // ───────────── Modération des publications ─────────────

  /// statut : 'pending' | 'approved' | 'rejected'
  Stream<List<PostModel>> publications(String statut) => _db
      .collection('posts')
      .where('status', isEqualTo: statut)
      .snapshots()
      .map((s) {
    final l = s.docs.map(PostModel.fromDoc).toList();
    l.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return l;
  });

  /// Accepte une publication et notifie son auteur (opération atomique).
  Future<void> accepter(PostModel p) {
    final batch = _db.batch();
    batch.update(_db.collection('posts').doc(p.id), {
      'status': 'approved',
      'reviewedBy': uid,
      'reviewedAt': FieldValue.serverTimestamp(),
      'rejectionReason': FieldValue.delete(),
    });
    batch.set(_db.collection('notifications').doc(), {
      'toUid': p.authorId,
      'fromUid': uid,
      'type': 'post_approved',
      'postId': p.id,
      'message': null,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return batch.commit();
  }

  /// Refuse une publication (avec un motif facultatif) et notifie l'auteur.
  Future<void> refuser(PostModel p, String motif) {
    final m = motif.trim();
    final batch = _db.batch();
    batch.update(_db.collection('posts').doc(p.id), {
      'status': 'rejected',
      'reviewedBy': uid,
      'reviewedAt': FieldValue.serverTimestamp(),
      'rejectionReason': m.isEmpty ? FieldValue.delete() : m,
    });
    batch.set(_db.collection('notifications').doc(), {
      'toUid': p.authorId,
      'fromUid': uid,
      'type': 'post_rejected',
      'postId': p.id,
      'message': m.isEmpty ? null : m,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return batch.commit();
  }
}