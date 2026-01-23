import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(FirebaseAuth.instance);
}

@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository(this._auth);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn(String email, String password) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      if ((normalizedEmail == 'admin@example.com' ||
              normalizedEmail == 'admin@gmail.com') &&
          (password == 'root' || password == 'root@123')) {
        // Special Case: Allow admin sign-in with specific passwords for testing/prompt requirements.
        // We still attempt real sign-in, but this marks where we might handle bypasses.
      }
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<UserCredential> signUp(
    String name,
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(name);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  bool isAdmin(String? email) {
    if (email == null) return false;
    final normalized = email.trim().toLowerCase();
    return normalized == 'admin@example.com' || normalized == 'admin@gmail.com';
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password provided is too weak.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
