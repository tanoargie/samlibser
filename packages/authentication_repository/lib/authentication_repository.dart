import 'dart:async';
import 'package:authentication_repository/errors.dart';
import 'package:authentication_repository/google_drive_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:cache/cache.dart';
import 'models/user.dart';

class AuthenticationRepository with GoogleDriveRepository {
  AuthenticationRepository(
      {CacheClient? cache,
      firebase_auth.FirebaseAuth? firebaseAuth,
      GoogleSignIn? googleSignIn})
      : _cache = cache ?? CacheClient(),
        _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
                clientId: const String.fromEnvironment("GOOGLE_CLIENT_ID"),
                scopes: [
                  'https://www.googleapis.com/auth/drive',
                  'https://www.googleapis.com/auth/drive.appdata',
                  'https://www.googleapis.com/auth/drive.file',
                  'https://www.googleapis.com/auth/drive.metadata'
                ]);

  final CacheClient _cache;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  @visibleForTesting
  bool isWeb = kIsWeb;

  @visibleForTesting
  static const userCacheKey = '__user_cache_key__';

  Stream<User> get user {
    return _firebaseAuth.idTokenChanges().asyncMap((firebaseUser) async {
      final user = firebaseUser == null ? User.empty : firebaseUser.toUser;
      _cache.write(key: userCacheKey, value: user);
      return user;
    });
  }

  Future<String?> getCurrentUserToken() async {
    firebase_auth.IdTokenResult? result =
        await _firebaseAuth.currentUser?.getIdTokenResult();
    return result?.token ?? '';
  }

  Future<String?> getCurrentUserUID() async {
    String? result = await _firebaseAuth.currentUser?.uid;
    return result ?? '';
  }

  User get currentUser {
    return _cache.read<User>(key: userCacheKey) ?? User.empty;
  }

  Future<void> signUp({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw SignUpWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (_) {
      throw const SignUpWithEmailAndPasswordFailure();
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _firebaseAuth.currentUser?.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw DeleteAccountFailure.fromCode(e.code);
    } catch (_) {
      throw const DeleteAccountFailure();
    }
  }

  Future<void> logInWithGoogle() async {
    try {
      late final firebase_auth.AuthCredential credential;
      if (isWeb) {
        final googleProvider = firebase_auth.GoogleAuthProvider();
        final userCredential = await _firebaseAuth.signInWithPopup(
          googleProvider,
        );
        credential = userCredential.credential!;
      } else {
        final googleUser = await _googleSignIn.signIn();
        final googleAuth = await googleUser!.authentication;
        credential = firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
      }
      final auth.AuthClient? client = await _googleSignIn.authenticatedClient();
      if (client == null) {
        throw const AuthClientNotInitializedFailure();
      } else {
        this.googleDriveApi = new drive.DriveApi(client);
      }

      await _firebaseAuth.signInWithCredential(credential);
      await _firebaseAuth.currentUser?.linkWithCredential(credential);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithGoogleFailure.fromCode(e.code);
    } catch (_) {
      throw const LogInWithGoogleFailure();
    }
  }

  Future<void> logInWithApple() async {
    try {
      late final firebase_auth.AuthCredential credential;
      final appleProvider = firebase_auth.AppleAuthProvider();
      appleProvider.addScope('email');
      appleProvider.addScope('name');
      if (isWeb) {
        final userCredential =
            await _firebaseAuth.signInWithPopup(appleProvider);
        credential = userCredential.credential!;
      } else {
        final userCredential =
            await _firebaseAuth.signInWithProvider(appleProvider);
        credential = userCredential.credential!;
      }

      await _firebaseAuth.signInWithCredential(credential);
      await _firebaseAuth.currentUser?.linkWithCredential(credential);
    } on firebase_auth.FirebaseAuthException catch (e) {
      //TODO: Logging
      throw LogInWithAppleFailure.fromCode(e.code);
    } catch (_) {
      //TODO: Logging
      throw const LogInWithAppleFailure();
    }
  }

  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      //TODO: Logging
      throw LogInWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (_) {
      //TODO: Logging
      throw const LogInWithEmailAndPasswordFailure();
    }
  }

  Future<void> resetPassword({required String password}) async {
    await _firebaseAuth.currentUser?.updatePassword(password);
  }

  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (_) {
      throw LogOutFailure();
    }
  }
}

extension on firebase_auth.User {
  User get toUser {
    return User(
        id: uid,
        email: email,
        name: displayName,
        providerId: providerData.first.providerId);
  }
}
