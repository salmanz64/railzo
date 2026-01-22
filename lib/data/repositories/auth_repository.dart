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
      if (email == 'admin@example.com' && password == 'root') {
        // Special Case: The user specifically requested 'root' as password.
        // Firebase requires 6 chars. We will try to sign in normally first.
        // If 'root' is not the real firebase password, we might need a workaround.
        // For this implementation, we will assume there is a real firebase user.
        // If not, we will throw a specific error or handle it.
        // However, we MUST returning a UserCredential to be compatible with the flow.
        // A client-side bypass for 'root' is tricky because we need a User object.
        // Let's attempt the real sign in. If it fails due to weak password (on creation)
        // that's a different issue. Here on sign-in, Firebase will just check against what's stored.
      }
      return await _auth.signInWithEmailAndPassword(
        email: email,
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
    return email == 'admin@example.com' || email == 'admin@gmail.com';
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
