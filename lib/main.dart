import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new MyApp());

class MessageList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('messages')
          .orderBy('date', descending: true)
          .snapshots,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        return new ListView(
          children: snapshot.data.documents.map((DocumentSnapshot document) {
            return new ListTile(
              title: new Text(document['user']),
              subtitle: new Text(document['message']),
            );
          }).toList(),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new InitChecker(),
    );
  }
}

class InitializePage extends StatelessWidget {
  TextEditingController _controller = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Center(
            child: new TextField(
      controller: _controller,
      onSubmitted: (value) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('user', value);
        Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new MyHomePage(value)));
      },
    )));
  }
}

class InitChecker extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new InitCheckerState();
  }
}

class InitCheckerState extends State<InitChecker> {
  void _getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('user');
    setState((){});
  }
  @override
  void initState(){
    _getPreferences();
  }

  String _userName;
  @override
  Widget build(BuildContext context) {
    if (_userName == null) {
      return new InitializePage();
    } else {
      return new MyHomePage(_userName);
    }
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage(this.userName);
  final userName;
  @override
  State<StatefulWidget> createState() {
    return new MyHomePageState(userName: userName);
  }
}

class MyHomePageState extends State<MyHomePage> {
  //CollectionReference get messages => Firestore.instance.collection('messages').orderBy('date', descending: false);
  MyHomePageState({this.userName});
  final userName;

  TextEditingController _messageController = new TextEditingController();

  _addMessage() {
    Firestore.instance
        .collection('messages')
        .document()
        .setData(<String, Object>{
      'user': userName,
      'message': _messageController.text,
      'date': new DateTime.now().millisecondsSinceEpoch
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Firestore Example'),
      ),
      body: new Column(children: [
        new TextField(
          decoration: new InputDecoration(helperText: "Message"),
          controller: _messageController,
        ),
        new Expanded(child: new MessageList()),
      ]),
      floatingActionButton: new FloatingActionButton(
        onPressed: _addMessage,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),
    );
  }
}
