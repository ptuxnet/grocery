import 'package:flutter/material.dart';

class Newitem extends StatefulWidget {
  const Newitem({super.key});

  @override
  State<Newitem> createState() => _NewitemState();
}

class _NewitemState extends State<Newitem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('ADD NEW ITEM'),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Text('add Item'),
      ),
    );
  }
}
