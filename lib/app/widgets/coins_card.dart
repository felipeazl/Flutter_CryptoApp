// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_size_text/auto_size_text.dart';
import 'package:crypto_app/app/config/app_setting.dart';
import 'package:crypto_app/app/repositories/favorite_repository.dart';
import 'package:crypto_app/app/pages/coins_details_page.dart';
import 'package:flutter/material.dart';

import 'package:crypto_app/app/models/coin_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CoinsCard extends StatefulWidget {
  final CoinModel coin;
  const CoinsCard({
    Key? key,
    required this.coin,
  }) : super(key: key);

  @override
  State<CoinsCard> createState() => _CoinsCardState();
}

class _CoinsCardState extends State<CoinsCard> {
  late NumberFormat currency;

  static Map<String, Color> priceColor = <String, Color>{
    "up": Colors.green,
    //"down": Colors.red,
    "down": Colors.indigo,
  };

  readNumberFormat() {
    final loc = context.watch<AppSettings>().locale;
    currency = NumberFormat.currency(locale: loc['locale'], name: loc['name']);
  }

  openDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoinsDetailsPage(coin: widget.coin),
      ),
    );
  }

  removeFavorite() {
    Navigator.pop(context);
    Provider.of<FavoriteRepository>(context, listen: false).remove(widget.coin);
  }

  @override
  Widget build(BuildContext context) {
    readNumberFormat();
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: 12),
      child: InkWell(
        onTap: openDetails,
        child: Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20, left: 20),
          child: Row(
            children: [
              Image.network(
                widget.coin.icon,
                height: 40,
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        widget.coin.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        maxFontSize: 18,
                        minFontSize: 16,
                      ),
                      Text(
                        widget.coin.acronym,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: priceColor["down"]!.withOpacity(0.05),
                  border: Border.all(
                    color: priceColor["down"]!.withOpacity(0.4),
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  currency.format(widget.coin.price),
                  style: TextStyle(
                    fontSize: 16,
                    color: priceColor["down"],
                    letterSpacing: -1,
                  ),
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: ListTile(
                      title: const Text("Remover"),
                      trailing: const Icon(Icons.delete),
                      onTap: removeFavorite,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
