import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthException implements Exception {
  String message;
  AuthException({
    required this.message,
  });
}

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  bool isLoading = true;

  AuthService() {
    _authCheck();
  }

  _authCheck() {
    _auth.authStateChanges().listen((User? authUser) {
      user = (authUser == null) ? null : authUser;
      isLoading = false;
      notifyListeners();
    });
  }

  _getUser() {
    user = _auth.currentUser;
    notifyListeners();
  }

  register(String email, String password, String name) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _auth.currentUser?.updateDisplayName(name);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == "week-password") {
        throw AuthException(message: "A senha é muito fraca.");
      } else if (e.code == "email-already-in-use") {
        throw AuthException(message: "Email já cadastrado.");
      }
    }
  }

  login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        throw AuthException(message: "Email não encontrado. Cadastre-se.");
      } else if (e.code == "wrong-password") {
        throw AuthException(message: "Senha incorreta. Tente novamente.");
      }
    }
  }

  logout() async {
    await _auth.signOut();
    _getUser();
  }
}
