import 'dart:io';

import 'package:contact_book/helpers/contact_helper.dart';
import 'package:flutter/material.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;

  ContactPage({this.contact});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  bool _userEdited = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  Contact? _editedContact = Contact();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact!.toMap());

      _nameController.text = _editedContact!.name;
      _emailController.text = _editedContact!.email;
      _phoneController.text = _editedContact!.phone;
    }
  }

  Future<bool> _resquestPop() async{
    if (_userEdited) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Descartar alteracoes?"),
            content: Text("Se sair sair as alteracoes serao perdidas!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancelar",
                ),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context); 
                    Navigator.pop(context); 
                  },
                  child: const Text(
                    "Sim!",
                  )
                ),
            ],
          );
        },
      );
      return Future.value(false); 
    }else{
      return Future.value(true); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _resquestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          title: Text((_editedContact?.name?.isNotEmpty ?? false)
              ? _editedContact!.name
              : "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact?.name != null &&
                _editedContact!.name.isNotEmpty) {
              Navigator.pop(context,
                  _editedContact); //Remove a tela atual e retorna para a anterior
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.purple,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: const InputDecoration(
                  label: Text("Nome"),
                  border: OutlineInputBorder(
                    
                  )
                ),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact?.name = text;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  label: Text("Email"),
                  border: OutlineInputBorder()
                ),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact?.phone = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  label: Text("Telefone"),
                  border: OutlineInputBorder()
                ),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
                keyboardType: TextInputType.phone,
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact?.email = text;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
