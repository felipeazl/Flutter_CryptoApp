// ignore_for_file: avoid_print

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:crypto_app/app/config/app_setting.dart';
import 'package:crypto_app/app/pages/camera_page.dart';
//import 'package:crypto_app/app/repositories/favorite_repository.dart';
import 'package:crypto_app/app/repositories/user_repository.dart';
import 'package:crypto_app/app/services/auth_service.dart';
import 'package:crypto_app/app/widgets/appbar.dart';
import 'package:crypto_app/app/widgets/button.dart';
import 'package:crypto_app/app/widgets/user_card.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({Key? key}) : super(key: key);

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  XFile? doc;

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance.currentUser;
    final user = context.watch<UserRepository>();
    final loc = context.read<AppSettings>().locale;
    final String email;
    final String name;

    if (auth != null) {
      email = auth.email!;
      name = auth.displayName!;
    } else {
      email = "Email";
      name = "Nome Completo";
    }

    NumberFormat currency =
        NumberFormat.currency(locale: loc["locale"], name: loc["name"]);

    return Scaffold(
      appBar: const CustomAppBar(title: "Configurações do Aplicativo"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              UserCard(name: name, email: email),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ListTile(
                  title: const Text("Saldo:"),
                  subtitle: Text(
                    currency.format(user.balance),
                    style: const TextStyle(
                      fontSize: 25,
                      color: Colors.indigo,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: updateBalance,
                  ),
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  "Configurações",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text("Tema do aplicativo"),
                      trailing: Icon(Icons.sunny),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: const Text("Escanear documento"),
                      trailing: const Icon(Icons.camera_alt),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CameraPage(),
                          fullscreenDialog: true,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: const Text("Enviar documento"),
                      trailing: const Icon(Icons.attach_file),
                      onTap: selectDoc,
                      leading: doc != null ? Image.file(File(doc!.path)) : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CustomButton(
                      title: "Reiniciar dados do aplicativo",
                      fontSizeText: 16,
                      icon: Icons.delete_forever,
                      paddingText: 16,
                      iconSize: 26,
                      onPressed: clearData,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: OutlinedButton(
                      onPressed: () => context.read<AuthService>().logout(),
                      style:
                          OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              "Sair do aplicativo",
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        ],
                      ),
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

  selectDoc() async {
    final ImagePicker picker = ImagePicker();

    try {
      XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) setState(() => doc = file);
    } catch (e) {
      print(e);
    }
  }

  clearData() async {
    final user = context.read<UserRepository>();
    //final favorites = context.read<FavoriteRepository>();

    AlertDialog dialog = AlertDialog(
      title: const Text("Deseja limpar todos os dados do aplicativo?"),
      content: Container(
        margin: const EdgeInsets.only(top: 20),
        child: const Icon(
          Icons.delete_forever,
          size: 44,
          color: Colors.black87,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        TextButton(
          onPressed: () {
            user.clearAllData("history");
            user.clearAllData("wallet");
            user.setBalance(0);
            Navigator.pop(context);
          },
          child: const Text("Deletar Dados"),
        )
      ],
    );
    showDialog(context: context, builder: (context) => dialog);
  }

  updateBalance() async {
    final form = GlobalKey<FormState>();
    final value = TextEditingController();
    final user = context.read<UserRepository>();

    value.text = user.balance.toString();

    AlertDialog dialog = AlertDialog(
      title: const Text("Atualizar Saldo"),
      content: Form(
        key: form,
        child: TextFormField(
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
          ],
          controller: value,
          validator: (value) {
            if (value!.isEmpty) return "Informe um valor";
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        TextButton(
          onPressed: () {
            if (form.currentState!.validate()) {
              user.setBalance(double.parse(value.text));
              Navigator.pop(context);
            }
          },
          child: const Text("Salvar"),
        )
      ],
    );

    showDialog(context: context, builder: (context) => dialog);
  }
}
