import 'package:buddiesgram/models/data.dart';
import 'package:buddiesgram/pages/StoryScreen.dart';
import 'package:flutter/material.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firestore.instance.settings();

  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechGram',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        dialogBackgroundColor: Colors.black,
        primarySwatch: Colors.grey,
        accentColor: Colors.black,
        cardColor: Colors.white70,
      ),
      home: HomePage(),
    );
  }
}
