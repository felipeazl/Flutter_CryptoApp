import 'package:crypto_app/app/models/coin_model.dart';

class HistoryModel {
  DateTime operationDate;
  String operationType;
  CoinModel coin;
  double valor;
  double qtd;

  HistoryModel({
    required this.operationDate,
    required this.operationType,
    required this.coin,
    required this.valor,
    required this.qtd,
  });
}
