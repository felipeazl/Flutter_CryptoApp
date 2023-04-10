// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/app/database/db_firestore.dart';
import 'package:crypto_app/app/models/coin_model.dart';
import 'package:crypto_app/app/repositories/coin_repository.dart';
import 'package:crypto_app/app/services/auth_service.dart';
import 'package:flutter/material.dart';

class FavoriteRepository extends ChangeNotifier {
  final List<CoinModel> _list = [];
  late FirebaseFirestore db;
  late AuthService auth;
  CoinRepository coins;

  FavoriteRepository({required this.auth, required this.coins}) {
    _startRepository();
  }

  _startRepository() async {
    await _startFirestore();
    await _readFavorites();
  }

  _startFirestore() {
    db = DBFirestore.get();
  }

  _readFavorites() async {
    if (auth.user != null && _list.isEmpty) {
      final snapshot =
          await db.collection('users/${auth.user!.uid}/favorites').get();
      snapshot.docs.forEach((document) {
        CoinModel coin = coins.database
            .firstWhere((coin) => coin.acronym == document.get("acronym"));
        _list.add(coin);
        notifyListeners();
      });
    }
  }

  UnmodifiableListView<CoinModel> get list => UnmodifiableListView(_list);

  saveAll(List<CoinModel> coins) {
    coins.forEach((coin) async {
      if (!_list.any((element) => element.acronym == coin.acronym)) {
        _list.add(coin);
        await db
            .collection('users/${auth.user!.uid}/favorites')
            .doc(coin.acronym)
            .set({
          "coin": coin.name,
          "acronym": coin.acronym,
          "price": coin.price
        });
      }
    });
    notifyListeners();
  }

  remove(CoinModel coin) async {
    await db
        .collection('users/${auth.user!.uid}/favorites')
        .doc(coin.acronym)
        .delete();
    _list.remove(coin);
    notifyListeners();
  }
}
