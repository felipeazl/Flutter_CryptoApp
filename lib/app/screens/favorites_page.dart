import 'package:crypto_app/app/repositories/favorite_repository.dart';
import 'package:crypto_app/app/widgets/appbar.dart';
import 'package:crypto_app/app/widgets/coins_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const CustomAppBar(title: "Moedas Favoritas"),
      body: Container(
        color: Colors.deepPurple.withOpacity(0.05),
        height: size.height,
        padding: const EdgeInsets.all(12),
        child: Consumer<FavoriteRepository>(
          builder: (context, favorites, child) {
            return favorites.list.isEmpty
                ? const ListTile(
                    leading: Icon(Icons.star),
                    title: Text('Ainda não há moedas favoritas'),
                  )
                : ListView.builder(
                    itemCount: favorites.list.length,
                    itemBuilder: (_, index) {
                      return CoinsCard(coin: favorites.list[index]);
                    },
                  );
          },
        ),
      ),
    );
  }
}
