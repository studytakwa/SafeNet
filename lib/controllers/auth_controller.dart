import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Stream<User?> get authStateStream => _authService.authStateChanges;

  User? get currentUser => _authService.currentUser;

  Future<void> seDeconnecter() async {
    await _authService.seDeconnecter();
  }
}
