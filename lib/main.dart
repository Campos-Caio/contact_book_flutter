import 'package:contact_book/UI/home_page.dart';
import 'package:contact_book/UI/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

final _storage = FlutterSecureStorage(); 

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          if (snapshot.data == true) {
            return HomePage();
          } else {
            return LoginPage();
          }
        }
      },
    );
  }

  Future<bool> _checkToken() async {
    String? username = await _storage.read(key: "username");
    return username != null;
  }
}
