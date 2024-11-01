import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:contact_book/helpers/contact_helper.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = FlutterSecureStorage(); 
  ContactHelper helper = ContactHelper();

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  // Verificar se há token no SharedPreferences
  _checkLogin() async {
    String? username = await _storage.read(key: 'username');
    if (username != null) {
      _navigateToHome();
    }
  }

  _navigateToHome() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  // Guardar o token
  _saveLogin(String username) async {
    await _storage.write(key: "username", value: username);
    _navigateToHome();
  }

  // Realizar o login
  _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    //bloco try-catch para caso de algum erro ao tentar logar
    try {
      var loginData = await helper.getLogin(username, password);
      if (loginData != null) {
        _saveLogin(username);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login realizado com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login ou senha inválidos')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao realizar login: $e')),
      );
    }
  }

  // Realizar o cadastro
  _register() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      try {
        var existingUser = await helper.getLogin(username, password);
        if (existingUser != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Usuário já cadastrado!')),
          );
          return;
        }

        await helper.saveLogin(username, password);
        _saveLogin(username);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário cadastrado com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao realizar cadastro: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Login"),
        backgroundColor: Colors.purple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.account_circle,
                size: 100,
                color: Colors.purple,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Usuário",
                  labelStyle: TextStyle(color: Colors.purple),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Senha",
                  labelStyle: TextStyle(color: Colors.purple),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text("Entrar"),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: _register,
                child: Text(
                  "Cadastrar",
                  style: TextStyle(color: Colors.purple, fontSize: 18),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
