import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groceryapp/data/categories.dart';
import 'package:groceryapp/models/grocery_item.dart';
import 'package:groceryapp/widgets/newitem.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItem = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // Method for load Items
  void _loadItems() async {
    final url = Uri.https(
        'grocery-b56cb-default-rtdb.asia-southeast1.firebasedatabase.app',
        'Grocery-list.json');

    final response = await http.get(url);

    final Map<String, dynamic> listData = json.decode(response.body);

    final List<GroceryItem> _loadedItems = [];

    for (final item in listData.entries) {
      final categroy = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      _loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: categroy,
        ),
      );
    }

    setState(() {
      _groceryItem = _loadedItems;
    });
  }

  // Method for New Item
  void addItem(BuildContext context) async {
    await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => Newitem(),
      ),
    );

    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text('No Item added yet'),
    );

    if (_groceryItem.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItem.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_groceryItem[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItem[index].category.color,
            ),
            trailing: Text(
              _groceryItem[index].quantity.toString(),
            ),
          );
        },
      );
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('GROCERIES'),
          actions: [
            IconButton(
              onPressed: () => addItem(context),
              icon: Icon(Icons.add),
            )
          ],
        ),
        body: content);
  }
}
