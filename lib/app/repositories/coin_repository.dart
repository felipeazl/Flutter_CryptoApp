import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import 'package:crypto_app/app/database/db.dart';
import 'package:crypto_app/app/models/coin_model.dart';

class CoinRepository extends ChangeNotifier {
  List<CoinModel> _database = [];
  late Timer interval;

  List<CoinModel> get database => _database;

  CoinRepository() {
    _setupCoinsDatabase();
    _setupDataCoinsTable();
    _readCoinsTable();
    _refreshPrices();
  }

  _refreshPrices() async {
    interval = Timer.periodic(const Duration(minutes: 5), (_) => checkPrices());
  }

  getCoinHistory(CoinModel coin) async {
    final response = await http.get(
      Uri.parse(
        'http://api.coinbase.com/v2/assets/prices/${coin.baseId}?base=BRL',
      ),
    );
    List<Map<String, dynamic>> prices = [];

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final Map<String, dynamic> coin = json['data']['prices'];

      prices.add(coin['hour']);
      prices.add(coin['day']);
      prices.add(coin['week']);
      prices.add(coin['month']);
      prices.add(coin['year']);
      prices.add(coin['all']);
    }

    return prices;
  }

  checkPrices() async {
    String uri = 'https://api.coinbase.com/v2/assets/search?base=BRL';
    final response = await http.get(Uri.parse(uri));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> coins = json['data'];
      Database db = await DB.instance.database;
      Batch batch = db.batch();

      _database.forEach((currentPrice) {
        coins.forEach((newPrice) {
          if (currentPrice == newPrice['base_id']) {
            final coin = newPrice['prices'];
            final price = coin['latest_price'];
            final timestamp = DateTime.parse(price['timestamp']);

            batch.update(
                'coins',
                {
                  'price': coin['latest'],
                  'timestamp': timestamp.millisecondsSinceEpoch,
                  'changeHour': price['percent_change']['hour'].toString(),
                  'changeDay': price['percent_change']['day'].toString(),
                  'changeWeek': price['percent_change']['week'].toString(),
                  'changeMonth': price['percent_change']['month'].toString(),
                  'changeYear': price['percent_change']['year'].toString(),
                  'changePeriod': price['percent_change']['all'].toString(),
                },
                where: 'baseId = ?',
                whereArgs: [currentPrice.baseId]);
          }
        });
      });
      await batch.commit(noResult: true);
      await _readCoinsTable();
    }
  }

  _readCoinsTable() async {
    Database db = await DB.instance.database;
    List results = await db.query('coins');

    _database = results.map((row) {
      return CoinModel(
        baseId: row['baseId'],
        icon: row['icon'],
        acronym: row['acronym'],
        name: row['name'],
        price: double.parse(row['price']),
        timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp']),
        changeHour: double.parse(row['changeHour']),
        changeDay: double.parse(row['changeDay']),
        changeWeek: double.parse(row['changeWeek']),
        changeMonth: double.parse(row['changeMonth']),
        changeYear: double.parse(row['changeYear']),
        changePeriod: double.parse(row['changePeriod']),
      );
    }).toList();

    notifyListeners();
  }

  _coinsTableIsEmpty() async {
    Database db = await DB.instance.database;
    List result = await db.query('coins');
    return result.isEmpty;
  }

  _setupDataCoinsTable() async {
    if (await _coinsTableIsEmpty()) {
      String uri = 'https://api.coinbase.com/v2/assets/search?base=BRL';

      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> coins = json['data'];
        Database db = await DB.instance.database;
        Batch batch = db.batch();

        coins.forEach((coin) {
          final price = coin['latest_price'];
          final timestamp = DateTime.parse(price['timestamp']);

          batch.insert('coins', {
            'baseId': coin['id'],
            'acronym': coin['symbol'],
            'name': coin['name'],
            'icon': coin['image_url'],
            'price': coin['latest'],
            'timestamp': timestamp.millisecondsSinceEpoch,
            'changeHour': price['percent_change']['hour'].toString(),
            'changeDay': price['percent_change']['day'].toString(),
            'changeWeek': price['percent_change']['week'].toString(),
            'changeMonth': price['percent_change']['month'].toString(),
            'changeYear': price['percent_change']['year'].toString(),
            'changePeriod': price['percent_change']['all'].toString(),
          });
        });
        await batch.commit(noResult: true);
      }
    }
  }

  _setupCoinsDatabase() async {
    final String table = '''
      CREATE TABLE IF NOT EXISTS coins (
        baseId TEXT PRIMARY KEY,
        acronym TEXT,
        name TEXT,
        icon TEXT,
        price TEXT,
        timestamp INTEGER,
        changeHour TEXT,
        changeDay TEXT,
        changeWeek TEXT,
        changeMonth TEXT,
        changeYear TEXT,
        changePeriod TEXT
      )
    ''';
    Database db = await DB.instance.database;
    await db.execute(table);
  }
}
