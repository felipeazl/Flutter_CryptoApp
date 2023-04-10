// ignore_for_file: use_build_context_synchronously

import 'package:crypto_app/app/config/app_setting.dart';
import 'package:crypto_app/app/widgets/chart_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:crypto_app/app/models/coin_model.dart';
import 'package:crypto_app/app/repositories/user_repository.dart';
import 'package:crypto_app/app/widgets/appbar.dart';
import 'package:crypto_app/app/widgets/button.dart';
import 'package:crypto_app/app/widgets/text_field.dart';

class CoinsDetailsPage extends StatefulWidget {
  final CoinModel coin;

  const CoinsDetailsPage({Key? key, required this.coin}) : super(key: key);

  @override
  State<CoinsDetailsPage> createState() => _CoinsDetailsPageState();
}

class _CoinsDetailsPageState extends State<CoinsDetailsPage> {
  late NumberFormat currency;
  final _form = GlobalKey<FormState>();
  final _value = TextEditingController();
  double qtd = 0;
  late UserRepository user;
  Widget chart = Container();
  bool chartLoaded = false;

  getChart() {
    if (!chartLoaded) {
      chart = ChartHistory(coin: widget.coin);
      chartLoaded = true;
    }
    return chart;
  }

  buyCoin() async {
    if (_form.currentState!.validate()) {
      //salvar compra
      await user.buy(widget.coin, double.parse(_value.text));

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Compra realizada com sucesso!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    user = Provider.of<UserRepository>(context, listen: false);
    readNumberFormat();
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.coin.name,
        leadingIcon: Icons.arrow_back,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      child: Image.network(
                        widget.coin.icon,
                        scale: 2.5,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      currency.format(widget.coin.price),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -1,
                        color: Colors.grey[800],
                      ),
                    )
                  ],
                ),
              ),
              getChart(),
              (qtd > 0)
                  ? SizedBox(
                      width: size.width,
                      child: Container(
                        margin: const EdgeInsets.only(top: 24, bottom: 24),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "$qtd ${widget.coin.acronym}",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(12),
                    ),
              Form(
                  key: _form,
                  child: CustomTextField(
                    controller: _value,
                    label: "Valor",
                    suffix: "R\$",
                    prefixIcon: Icons.monetization_on_outlined,
                    inputType: TextInputType.number,
                    inputFormatter: [FilteringTextInputFormatter.digitsOnly],
                    validators: (value) {
                      if (value!.isEmpty) {
                        return "Digite um valor para compra";
                      } else if (double.parse(value) < 50) {
                        return "Valor mínimo para compra de R\$ 50,00";
                      } else if (double.parse(value) > user.balance) {
                        return "Saldo insuficiente para essa operação";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        qtd = (value.isEmpty)
                            ? 0
                            : double.parse(value) / widget.coin.price;
                      });
                    },
                  )),
              Container(
                alignment: Alignment.bottomCenter,
                margin: const EdgeInsets.only(top: 24),
                child: CustomButton(
                  title: "Comprar",
                  fontSizeText: 20,
                  onPressed: buyCoin,
                  icon: Icons.check,
                  paddingText: 16,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  readNumberFormat() {
    final loc = context.watch<AppSettings>().locale;
    currency = NumberFormat.currency(locale: loc['locale'], name: loc['name']);
  }
}
