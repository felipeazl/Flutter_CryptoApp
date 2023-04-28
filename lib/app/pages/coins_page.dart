import 'package:auto_size_text/auto_size_text.dart';
import 'package:crypto_app/app/config/app_setting.dart';
import 'package:crypto_app/app/models/coin_model.dart';
import 'package:crypto_app/app/repositories/coin_repository.dart';
import 'package:crypto_app/app/repositories/favorite_repository.dart';
import 'package:crypto_app/app/pages/coins_details_page.dart';
import 'package:crypto_app/app/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CoinsPage extends StatefulWidget {
  const CoinsPage({Key? key}) : super(key: key);

  @override
  State<CoinsPage> createState() => _CoinsPageState();
}

class _CoinsPageState extends State<CoinsPage> {
  late List<CoinModel> data;
  List<CoinModel> selected = [];
  late FavoriteRepository favorites;
  late CoinRepository coins;

  late NumberFormat currency;
  late Map<String, String> loc;

  readNumberFormat() {
    loc = context.watch<AppSettings>().locale;
    currency = NumberFormat.currency(
      locale: loc['locale'],
      symbol: loc['symbol'],
    );
  }

  changeLanguageButton() {
    final locale = loc['locale'] == 'pt_BR' ? 'en_US' : 'pt_BR';
    final symbol = loc['locale'] == 'pt_BR' ? '\$' : 'R\$';

    return PopupMenuButton(
      icon: const Icon(Icons.language),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: ListTile(
            trailing: const Icon(Icons.swap_vert),
            title: Text('Trocar para $locale'),
            onTap: () {
              context.read<AppSettings>().setLocale(locale, symbol);
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  showDetails(CoinModel coin) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoinsDetailsPage(
          coin: coin,
        ),
      ),
    );
  }

  selectCoin(CoinModel coin) {
    setState(() {
      (selected.contains(coin) ? selected.remove(coin) : selected.add(coin));
    });
  }

  removeSelected() {
    setState(() {
      selected = [];
    });
  }

  addFavorite() {
    favorites.saveAll(selected);
    removeSelected();
  }

  @override
  Widget build(BuildContext context) {
    // favorites = Provider.of<FavoriteRepository>(context);
    favorites = context.watch<FavoriteRepository>();
    coins = context.watch<CoinRepository>();
    data = coins.database;
    readNumberFormat();

    return Scaffold(
      appBar: selected.isEmpty
          ? CustomAppBar(
              title: "CryptoWallet",
              action: [
                changeLanguageButton(),
              ],
            )
          : CustomAppBar(
              title: "${selected.length} moedas selecionadas",
              backgroundColor: Colors.indigo[50],
              leadingIcon: Icons.clear,
              textColor: Colors.black87,
              onPressed: removeSelected,
            ),
      body: RefreshIndicator(
        onRefresh: () => coins.checkPrices(),
        child: ListView.separated(
          itemBuilder: (BuildContext context, int coin) {
            return ListTile(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              leading: selected.contains(data[coin])
                  ? const CircleAvatar(child: Icon(Icons.check))
                  : SizedBox(
                      child: Image.network(
                        data[coin].icon,
                        width: 40,
                      ),
                    ),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AutoSizeText(
                    data[coin].name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    maxFontSize: 18,
                    minFontSize: 16,
                    maxLines: 1,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  if (favorites.list.any(
                      (favorite) => favorite.acronym == data[coin].acronym))
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20,
                    )
                ],
              ),
              subtitle: Text(data[coin].acronym),
              trailing: Text(currency.format(data[coin].price)),
              selected: selected.contains(data[coin]),
              selectedTileColor: Colors.indigo[50],
              onLongPress: () => selectCoin(data[coin]),
              onTap: selected.isEmpty
                  ? () => showDetails(data[coin])
                  : () => selectCoin(data[coin]),
            );
          },
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, __) => const Divider(),
          itemCount: data.length,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: selected.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: addFavorite,
              icon: const Icon(Icons.star),
              label: const Text(
                "FAVORITAR",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0,
                ),
              ),
            )
          : null,
    );
  }
}
