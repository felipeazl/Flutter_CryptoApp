import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:crypto_app/app/app.dart';
import 'package:crypto_app/app/config/app_setting.dart';
import 'package:crypto_app/app/config/hive_config.dart';
import 'package:crypto_app/app/repositories/coin_repository.dart';
import 'package:crypto_app/app/repositories/favorite_repository.dart';
import 'package:crypto_app/app/repositories/user_repository.dart';
import 'package:crypto_app/app/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.start();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => CoinRepository()),
        ChangeNotifierProvider(
          create: (context) => UserRepository(
            coins: context.read<CoinRepository>(),
          ),
        ),
        ChangeNotifierProvider(create: (context) => AppSettings()),
        ChangeNotifierProvider(
          create: (context) => FavoriteRepository(
            auth: context.read<AuthService>(),
            coins: context.read<CoinRepository>(),
          ),
        ),
      ],
      child: const App(),
    ),
  );
}
