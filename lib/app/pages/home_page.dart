import 'package:crypto_app/app/pages/configs_page.dart';
import 'package:crypto_app/app/pages/coins_page.dart';
import 'package:crypto_app/app/pages/favorites_page.dart';
import 'package:crypto_app/app/pages/wallet_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double iconSize = 28;
  int currentPage = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentPage);
  }

  setCurrentPage(page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: setCurrentPage,
        children: const [
          CoinsPage(),
          FavoritesPage(),
          WalletPage(),
          ConfigPage(),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.indigo.withOpacity(0.1),
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        child: NavigationBar(
          selectedIndex: currentPage,
          onDestinationSelected: (page) {
            pageController.animateToPage(
              page,
              duration: const Duration(milliseconds: 400),
              curve: Curves.ease,
            );
          },
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
                size: iconSize,
              ),
              label: "Home",
              selectedIcon: Icon(
                Icons.home,
                size: iconSize,
              ),
            ),
            NavigationDestination(
              icon: Icon(
                Icons.star_outline,
                size: iconSize,
              ),
              label: "Favoritas",
              selectedIcon: Icon(
                Icons.star,
                size: iconSize,
              ),
            ),
            NavigationDestination(
              icon: Icon(
                Icons.account_balance_wallet_outlined,
                size: iconSize,
              ),
              label: "Carteira",
              selectedIcon: Icon(
                Icons.account_balance_wallet,
                size: iconSize,
              ),
            ),
            NavigationDestination(
              icon: Icon(
                Icons.settings_outlined,
                size: iconSize,
              ),
              label: "Configurações",
              selectedIcon: Icon(
                Icons.settings,
                size: iconSize,
              ),
            )
          ],
        ),
      ),
    );
  }
}
