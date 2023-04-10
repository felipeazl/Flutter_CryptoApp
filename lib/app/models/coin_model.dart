class CoinModel {
  String baseId;
  String icon;
  String name;
  String acronym;
  double price;
  DateTime timestamp;
  double changeHour;
  double changeDay;
  double changeWeek;
  double changeMonth;
  double changeYear;
  double changePeriod;

  CoinModel({
    required this.baseId,
    required this.icon,
    required this.name,
    required this.acronym,
    required this.price,
    required this.timestamp,
    required this.changeHour,
    required this.changeDay,
    required this.changeWeek,
    required this.changeMonth,
    required this.changeYear,
    required this.changePeriod,
  });
}
