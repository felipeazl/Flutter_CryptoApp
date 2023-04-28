import 'package:crypto_app/app/config/app_setting.dart';
import 'package:crypto_app/app/models/value_model.dart';
import 'package:crypto_app/app/repositories/user_repository.dart';
import 'package:crypto_app/app/widgets/appbar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  int index = 0;
  double totalWallet = 0;
  double balance = 0;
  late NumberFormat currency;
  late UserRepository user;

  String chartLabel = "";
  double chartValue = 0;
  List<ValueModel> wallet = [];

  @override
  Widget build(BuildContext context) {
    user = context.watch<UserRepository>();
    final loc = context.read<AppSettings>().locale;
    currency = NumberFormat.currency(
      locale: loc["locale"],
      name: loc["name"],
    );
    balance = user.balance;

    setTotalWallet();

    return Scaffold(
      appBar: const CustomAppBar(
        title: "Carteira de Investimentos",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 48, bottom: 8),
              child: Text("Valor da Carteira"),
            ),
            Text(
              currency.format(totalWallet),
              style: const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                letterSpacing: -1.5,
              ),
            ),
            loadChart(),
            loadHistory(),
          ],
        ),
      ),
    );
  }

  setTotalWallet() {
    final walletList = user.wallet;
    setState(() {
      totalWallet = user.balance;
      for (var i in walletList) {
        totalWallet += i.coin.price * i.qtd;
      }
    });
  }

  setChartData(int index) {
    if (index < 0) return;

    if (index == wallet.length) {
      chartLabel = "Saldo";
      chartValue = user.balance;
    } else {
      chartLabel = wallet[index].coin.name;
      chartValue = wallet[index].coin.price * wallet[index].qtd;
    }
  }

  loadWallet() {
    setChartData(index);
    wallet = user.wallet;
    final walletLength = wallet.length + 1;

    return List.generate(walletLength, (i) {
      final isTouched = i == index;
      final isBalance = i == walletLength - 1;
      final fontSize = isTouched ? 18.0 : 14.0;
      final radius = isTouched ? 60.0 : 50.0;
      final color = isTouched ? Colors.indigo[200] : Colors.indigo;

      double percentage = 0;

      if (!isBalance) {
        percentage = wallet[i].coin.price * wallet[i].qtd / totalWallet;
      } else {
        percentage = (user.balance > 0) ? user.balance / totalWallet : 0;
      }
      percentage *= 100;

      return PieChartSectionData(
        color: color,
        value: percentage,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      );
    });
  }

  loadChart() {
    return (user.balance <= 0)
        ? SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                      sectionsSpace: 5,
                      centerSpaceRadius: 110,
                      sections: loadWallet(),
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              index = -1;
                              return;
                            }
                            index = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                            setChartData(index);
                          });
                        },
                      )),
                ),
              ),
              Column(
                children: [
                  Text(
                    chartLabel,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.indigo,
                    ),
                  ),
                  Text(
                    currency.format(chartValue),
                    style: const TextStyle(fontSize: 28),
                  )
                ],
              )
            ],
          );
  }

  loadHistory() {
    final history = user.history;
    final date = DateFormat("dd/MM/yyyy - HH:mm");
    List<Widget> widgets = [];

    for (var operation in history) {
      widgets.insert(
        0,
        Column(
          children: [
            ListTile(
              title: Text(operation.coin.name),
              subtitle: Text(date.format(operation.operationDate)),
              trailing:
                  Text(currency.format((operation.coin.price * operation.qtd))),
            ),
            const Divider(),
          ],
        ),
      );
    }
    return Column(
      children: widgets,
    );
  }
}
