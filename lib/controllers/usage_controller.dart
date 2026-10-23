import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/usage_service.dart';

class UsageController extends ChangeNotifier with WidgetsBindingObserver {
  static const int dailyLimit = 2 * 60 * 60; // 2 heures en secondes

  final _service = UsageService();
  Timer? _timer;
  int _usedSeconds = 0;   // total déjà sauvegardé + en cours
  int _unsaved = 0;       // secondes pas encore envoyées à Firestore

  int get remainingSeconds => (dailyLimit - _usedSeconds).clamp(0, dailyLimit);
  bool get limitReached => _usedSeconds >= dailyLimit;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> start() async {
    final uid = _uid;
    if (uid == null) return;
    WidgetsBinding.instance.addObserver(this);
    _usedSeconds = await _service.getTodaySeconds(uid);
    notifyListeners();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (limitReached) {
        _flush();
        _timer?.cancel();
        notifyListeners();
        return;
      }
      _usedSeconds++;
      _unsaved++;
      if (_unsaved >= 30) _flush(); // sauvegarde toutes les 30 s
      notifyListeners();
    });
  }

  Future<void> _flush() async {
    final uid = _uid;
    if (uid == null || _unsaved == 0) return;
    final toSave = _unsaved;
    _unsaved = 0;
    await _service.addSeconds(uid, toSave);
  }

  // Compter seulement quand l'app est visible
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      start(); // recharge depuis Firestore (gère aussi le changement de jour)
    } else {
      _timer?.cancel();
      _flush();
    }
  }

  void stop() {
    _timer?.cancel();
    _flush();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}