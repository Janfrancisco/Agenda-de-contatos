import 'dart:io';

import 'package:agenda_de_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  ContactPage({this.contact});

  final Contact contact;

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact _edtContact;
  bool _userEdited = false;

  //EditingControllers dos input Texts
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _edtContact = Contact();
    } else {
      _edtContact = Contact.fromMap(widget.contact.toMap());
      _nameController.text = _edtContact.name;
      _emailController.text = _edtContact.email;
      _phoneController.text = _edtContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
            title: Text(_edtContact.name ?? 'Novo Contato'),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (_edtContact.name != null && _edtContact.name.isNotEmpty) {
                  Navigator.pop(context, _edtContact);
                } else {
                  //Envio o foco para o campo 'name'
                  FocusScope.of(context).requestFocus(_nameFocus);
                }
              },
              child: Icon(Icons.save),
              backgroundColor: Colors.red),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    width: 140.0,
                    height: 140.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: _edtContact.img != null
                              ? FileImage(File(_edtContact.img))
                              : AssetImage('images/person.png')),
                    ),
                  ),
                  onTap: () {
                    /* ImageSource imgSrc;
                    if (_edtContact.name == null) {
                      imgSrc = ImageSource.camera;
                    } else {
                      imgSrc = ImageSource.gallery;
                    } */

                    ImagePicker()
                        .getImage(source: ImageSource.camera)
                        .then((file) {
                      if (file.path == null) return;
                      setState(() {
                        File image = File(file.path);
                        _edtContact.img = image.path;
                      });
                    });
                  },
                ),
                TextField(
                  focusNode: _nameFocus,
                  decoration: InputDecoration(labelText: "Nome"),
                  onChanged: (text) {
                    _userEdited = true;
                    setState(() {
                      _edtContact.name = text;
                    });
                  },
                  controller: _nameController,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Email"),
                  onChanged: (text) {
                    _userEdited = true;
                    _edtContact.email = text;
                  },
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Phone"),
                  onChanged: (text) {
                    _userEdited = true;
                    _edtContact.phone = text;
                  },
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                ),
              ],
            ),
          ),
        ),
        //Trata a ação do botão Voltar
        onWillPop: _requestPop);
  }

  //Método que trata as ações do botão voltar
  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Descartar alterações'),
              content: Text("Se sair, as alterações serão perdidas"),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancerlar'),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text('Sim'),
                ),
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
