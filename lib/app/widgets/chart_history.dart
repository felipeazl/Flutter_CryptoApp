// ignore_for_file: must_be_immutable

import 'package:crypto_app/app/config/app_setting.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:crypto_app/app/models/coin_model.dart';
import 'package:crypto_app/app/repositories/coin_repository.dart';
import 'package:provider/provider.dart';

class ChartHistory extends StatefulWidget {
  CoinModel coin;

  ChartHistory({
    Key? key,
    required this.coin,
  }) : super(key: key);

  @override
  State<ChartHistory> createState() => _ChartHistoryState();
}

enum Period { hour, day, week, month, year, total }

class _ChartHistoryState extends State<ChartHistory> {
  List<Color> colors = [
    const Color(0xFF4050b5),
  ];
  Period period = Period.hour;
  List<Map<String, dynamic>> history = [];
  List fullData = [];
  List<FlSpot> charData = [];
  double maxX = 0;
  double maxY = 0;
  double minY = 0;
  ValueNotifier<bool> loaded = ValueNotifier(false);
  late CoinRepository repository;
  late Map<String, String> loc;
  late NumberFormat currency;

  setData() async {
    loaded.value = false;
    charData = [];

    if (history.isEmpty) history = await repository.getCoinHistory(widget.coin);

    fullData = history[period.index]['prices'];
    fullData = fullData.reversed.map((item) {
      double price = double.parse(item[0]);
      int time = int.parse('${item[1]}000');
      return [price, DateTime.fromMillisecondsSinceEpoch(time)];
    }).toList();

    maxX = fullData.length.toDouble();
    maxY = 0;
    minY = double.infinity;

    for (var item in fullData) {
      maxY = item[0] > maxY ? item[0] : maxY;
      minY = item[0] < minY ? item[0] : minY;
    }

    for (int i = 0; i < fullData.length; i++) {
      charData.add(FlSpot(
        i.toDouble(),
        fullData[i][0],
      ));
    }

    loaded.value = true;
  }

  LineChartData getChartData() {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: maxX,
      maxY: maxY,
      minY: minY,
      lineBarsData: [
        LineChartBarData(
          spots: charData,
          isCurved: true,
          color: colors[0],
          barWidth: 2,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: colors[0].withOpacity(0.15),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: const Color(0xFF343434),
          getTooltipItems: (data) {
            return data.map((item) {
              final date = getDate(item.spotIndex);
              return LineTooltipItem(
                  currency.format(item.y),
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: '\n $date',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    )
                  ]);
            }).toList();
          },
        ),
      ),
    );
  }

  getDate(int index) {
    DateTime date = fullData[index][1];
    if (period != Period.year && period != Period.total) {
      return DateFormat('dd/MM - hh:mm').format(date);
    } else {
      return DateFormat('dd/MM/y').format(date);
    }
  }

  chartButton(Period p, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton(
        onPressed: () => setState(() => period = p),
        style: (period != p)
            ? ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.grey),
              )
            : ButtonStyle(
                foregroundColor: MaterialStateProperty.all(
                  Colors.indigo,
                ),
              ),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    repository = context.read<CoinRepository>();
    loc = context.read<AppSettings>().locale;
    currency = NumberFormat.currency(locale: loc['locale'], name: loc['name']);
    setData();

    return Container(
      child: AspectRatio(
        aspectRatio: 2,
        child: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  chartButton(Period.hour, '1H'),
                  chartButton(Period.day, '24H'),
                  chartButton(Period.week, '7D'),
                  chartButton(Period.month, 'Mês'),
                  chartButton(Period.year, 'Ano'),
                  chartButton(Period.total, 'Total'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: ValueListenableBuilder(
                valueListenable: loaded,
                builder: (context, bool isLoaded, _) {
                  return (isLoaded)
                      ? LineChart(
                          getChartData(),
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
