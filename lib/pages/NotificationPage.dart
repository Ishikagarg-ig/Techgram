import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Text('Here goes Activity feed page');
  }
}


class NotificationItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Activity feed items goes here');
  }
}
