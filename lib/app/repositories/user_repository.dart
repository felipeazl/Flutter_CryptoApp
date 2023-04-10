// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:crypto_app/app/models/history_model.dart';
import 'package:crypto_app/app/repositories/coin_repository.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

import 'package:crypto_app/app/database/db.dart';
import 'package:crypto_app/app/models/coin_model.dart';
import 'package:crypto_app/app/models/value_model.dart';

class UserRepository extends ChangeNotifier {
  late Database db;
  List<ValueModel> _wallet = [];
  List<HistoryModel> _history = [];
  double _balance = 0;
  CoinRepository coins;

  get balance => _balance;
  List<ValueModel> get wallet => _wallet;
  List<HistoryModel> get history => _history;

  UserRepository({required this.coins}) {
    _initRepository();
  }

  _initRepository() async {
    await _getBalance();
    await _getWallet();
    await _getHistory();
  }

  _getBalance() async {
    db = await DB.instance.database;
    List user = await db.query('user', limit: 1);
    _balance = user.first['balance'];
    notifyListeners();
  }

  setBalance(double value) async {
    db = await DB.instance.database;
    db.update('user', {'balance': value});
    _balance = value;
    notifyListeners();
  }

  buy(CoinModel coin, double value) async {
    db = await DB.instance.database;
    await db.transaction((txn) async {
      //Check if the coin has already been purchased
      final position = await txn.query(
        'wallet',
        where: 'acronym = ?',
        whereArgs: [coin.acronym],
      );
      //If don't have the coin in wallet
      if (position.isEmpty) {
        await txn.insert('wallet', {
          'acronym': coin.acronym,
          'coin': coin.name,
          'qtd': (value / coin.price).toString(),
        });
      }
      //Already have the coin in wallet
      else {
        final currentQtd = double.parse(position.first['qtd'].toString());
        await txn.update(
          'wallet',
          {
            'qtd': (currentQtd + (value / coin.price)).toString(),
          },
          where: 'acronym = ?',
          whereArgs: [coin.acronym],
        );
      }
      //Add buy on history
      await txn.insert('history', {
        'acronym': coin.acronym,
        'coin': coin.name,
        'qtd': (value / coin.price).toString(),
        'value': value,
        'operation_type': 'compra',
        'operation_date': DateTime.now().millisecondsSinceEpoch
      });

      //Update balance
      await txn.update('user', {
        'balance': balance - value,
      });
    });
    await _initRepository();
    notifyListeners();
  }

  _getWallet() async {
    _wallet = [];
    List positions = await db.query('wallet');
    positions.forEach((position) {
      CoinModel coin = coins.database.firstWhere(
        (c) => c.acronym == position['acronym'],
      );
      _wallet.add(ValueModel(
        coin: coin,
        qtd: double.parse(position['qtd']),
      ));
    });
    notifyListeners();
  }

  _getHistory() async {
    _history = [];
    List operations = await db.query('history');
    operations.forEach((operation) {
      CoinModel coin = coins.database.firstWhere(
        (m) => m.acronym == operation['acronym'],
      );
      _history.add(
        HistoryModel(
          operationDate: DateTime.fromMillisecondsSinceEpoch(
              operation['operation_date'],
              isUtc: false),
          operationType: operation['operation_type'],
          coin: coin,
          valor: operation['value'],
          qtd: double.parse(operation['qtd']),
        ),
      );
    });
    notifyListeners();
  }

  clearAllData(String tableName) async {
    db = await DB.instance.database;
    db.rawQuery('DELETE FROM $tableName');
    await _initRepository();
    notifyListeners();
  }
}
