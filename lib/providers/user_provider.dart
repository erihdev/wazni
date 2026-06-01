import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wazni/models/user_model.dart';
import 'package:wazni/services/firebase_service.dart';

/// نفس نمط ZyiarahUserProvider
class WazniUserProvider extends ChangeNotifier {
  WazniUser? _user;
  bool _isLoading = true;
  StreamSubscription<User?>? _authSub;

  WazniUser? get user      => _user;
  bool get isLoading       => _isLoading;
  bool get isAuthenticated => _user != null;

  WazniUserProvider() {
    _authSub = WazniFirebaseService.instance.authStateChanges.listen(_onAuthChange);
  }

  Future<void> _onAuthChange(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user      = null;
      _isLoading = false;
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    _user      = await WazniFirebaseService.instance.getUser(firebaseUser.uid);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_user == null) return;
    _user = await WazniFirebaseService.instance.getUser(_user!.uid);
    notifyListeners();
  }

  void updateLocal(WazniUser updated) {
    _user = updated;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
