import 'dart:io';

import 'package:agenda_de_contatos/helpers/contact_helper.dart';
import 'package:agenda_de_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper contactHelper = ContactHelper();
  //List contacts = List();
  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();
    /* Contact ct = Contact();
    ct.name = "Rafa";
    ct.email = "dfer@gmail.com";
    ct.phone = '3524-5699';
    ct.img = 'teffd/bffmfmf/ff';

    contactHelper.saveContact(ct) */

    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contatos'),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton(
              onSelected: _orderList,
              itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
                    const PopupMenuItem(
                        child: Text('Ordenar de A-Z'),
                        value: OrderOptions.orderaz),
                    const PopupMenuItem(
                        child: Text('Ordenar de Z-A'),
                        value: OrderOptions.orderza),
                  ])
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showContactPage();
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.red),
      body: _showWidget(),
    );
  }

  Widget contactCard(BuildContext ctx, int index) {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Card(
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: contacts[index].img != null
                          ? FileImage(File(contacts[index].img))
                          : AssetImage('images/person.png')),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      contacts[index].name ?? "",
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      contacts[index].email ?? "",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      contacts[index].phone ?? "",
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        //showContactPage(contact: contacts[index]);
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext ctx, int index) {
    showModalBottomSheet(
        context: ctx,
        builder: (ctx) {
          return BottomSheet(
              onClosing: () {},
              builder: (ctx) {
                return Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: FlatButton(
                          onPressed: () {
                            launch('tel:${contacts[index].phone}');
                            Navigator.pop(ctx);
                          },
                          child: Text(
                            "Ligar",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: FlatButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            showContactPage(contact: contacts[index]);
                          },
                          child: Text(
                            "Editar",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: FlatButton(
                          onPressed: () {
                            setState(() {
                              contactHelper.deleteContact(contacts[index].id);
                              setState(() {
                                contacts.removeAt(index);
                                Navigator.pop(ctx);
                              });
                            });
                          },
                          child: Text(
                            "Excluir",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }

  void showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));
    if (recContact != null) {
      if (contact != null) {
        await contactHelper.updateContact(recContact);
      } else {
        await contactHelper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    contactHelper.getAllContact().then((value) {
      setState(() {
        contacts = value;
        print(contacts.length);
      });
    });
  }

  void _orderList(OrderOptions result) {
    print('_orderList');
    switch (result) {
      case OrderOptions.orderaz:
        contacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {});
  }

  //Exibe um texto no centro da tela, caso a lista estiver vazia
  Widget _showWidget() {
    if (contacts.length > 0) {
      return ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (BuildContext ctx, int index) {
          return contactCard(ctx, index);
          //return cardContact(index, contacts); // usando um widget stateless
        },
      );
    } else {
      return Center(
        child: Text(
          'A lista está vazia!',
          style: TextStyle(color: Colors.red, fontSize: 18.0),
        ),
      );
    }
  }
}

class cardContact extends StatelessWidget {
  cardContact(this.index, this.contacts);
  final int index;
  final List contacts;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Card(
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image:
                      DecorationImage(image: AssetImage('images/person.png')),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      contacts[index].name ?? "",
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      contacts[index].email ?? "",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      contacts[index].phone ?? "",
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {},
    );
  }
}
