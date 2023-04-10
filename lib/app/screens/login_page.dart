import 'package:crypto_app/app/services/auth_service.dart';
import 'package:crypto_app/app/widgets/button.dart';
import 'package:crypto_app/app/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  bool isLogin = true;

  late String title;
  late String actionButton;
  late String toggleButton;

  bool loading = false;

  bool showPassword = true;
  IconData visibility = Icons.visibility;

  @override
  void initState() {
    super.initState();
    setFormAction(true);
  }

  setFormAction(bool action) {
    setState(() {
      isLogin = action;
      if (isLogin) {
        title = "Bem Vindo";
        actionButton = "Entrar";
        toggleButton = "Ainda não tem conta? Cadastre-se agora.";
      } else {
        title = "Criar Conta";
        actionButton = "Cadastrar";
        toggleButton = "Já tem uma conta? Voltar ao Login.";
      }
    });
  }

  login() async {
    setState(() => loading = true);
    try {
      await context.read<AuthService>().login(email.text, password.text);
    } on AuthException catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  register() async {
    setState(() => loading = true);
    try {
      await context
          .read<AuthService>()
          .register(email.text, password.text, name.text);
    } on AuthException catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: (isLogin)
              ? Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: CustomTextField(
                          controller: email,
                          fontSize: 18,
                          label: "Email",
                          prefixIcon: Icons.mail,
                          inputType: TextInputType.emailAddress,
                          validators: (value) {
                            if (value!.isEmpty) {
                              return "Informe um email válido.";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        child: CustomTextField(
                          controller: password,
                          fontSize: 18,
                          label: "Senha",
                          prefixIcon: Icons.password,
                          suffixIcon: IconButton(
                            icon: Icon(visibility),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                                if (showPassword) {
                                  visibility = Icons.visibility;
                                } else {
                                  visibility = Icons.visibility_off;
                                }
                              });
                            },
                          ),
                          obscure: showPassword,
                          validators: (value) {
                            if (value!.isEmpty) {
                              return "Informe sua senha de acesso.";
                            } else if (value.length < 8) {
                              return "Sua senha deve ter no mínimo 8 caracteres";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: (loading)
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(),
                              )
                            : CustomButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    if (isLogin) {
                                      login();
                                    }
                                  }
                                },
                                title: actionButton,
                                fontSizeText: 20,
                                icon: Icons.check,
                                paddingText: 16,
                              ),
                      ),
                      TextButton(
                        onPressed: () => setFormAction(!isLogin),
                        child: Text(toggleButton),
                      )
                    ],
                  ),
                )
              : Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                        child: CustomTextField(
                          controller: name,
                          fontSize: 18,
                          label: "Nome Completo",
                          prefixIcon: Icons.person,
                          inputType: TextInputType.name,
                          validators: (value) {
                            if (value!.isEmpty) {
                              return "Informe seu nome completo.";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: CustomTextField(
                          controller: email,
                          fontSize: 18,
                          label: "Email",
                          prefixIcon: Icons.mail,
                          inputType: TextInputType.emailAddress,
                          validators: (value) {
                            if (value!.isEmpty) {
                              return "Informe um email válido.";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        child: CustomTextField(
                          controller: password,
                          fontSize: 18,
                          label: "Senha",
                          prefixIcon: Icons.password,
                          suffixIcon: IconButton(
                            icon: Icon(visibility),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                                if (showPassword) {
                                  visibility = Icons.visibility;
                                } else {
                                  visibility = Icons.visibility_off;
                                }
                              });
                            },
                          ),
                          obscure: showPassword,
                          validators: (value) {
                            if (value!.isEmpty) {
                              return "Informe sua senha de acesso.";
                            } else if (value.length < 8) {
                              return "Sua senha deve ter no mínimo 8 caracteres";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: (loading)
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(),
                              )
                            : CustomButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    if (!isLogin) {
                                      register();
                                    }
                                  }
                                },
                                title: actionButton,
                                fontSizeText: 20,
                                icon: Icons.check,
                                paddingText: 16,
                              ),
                      ),
                      TextButton(
                        onPressed: () => setFormAction(!isLogin),
                        child: Text(toggleButton),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
