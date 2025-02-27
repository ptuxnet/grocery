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
  var isLoading = true;
  String? _error;

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

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error =
              'Oops! Something went wrong while fetching data. Please try again soon.';
          isLoading = false;
        });
        return;
      }

      // Handle empty or null response
      if (response.body.isEmpty ||
          response.body.isEmpty ||
          response.body == 'null') {
        setState(() {
          isLoading = false;
          _groceryItem = [];
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);

      // If listData is null or empty after decoding
      if (listData.isEmpty) {
        setState(() {
          isLoading = false;
          _groceryItem = [];
        });
        return;
      }

      final List<GroceryItem> loadedItems = [];

      for (final item in listData.entries) {
        final categroy = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: categroy,
          ),
        );
      }

      setState(() {
        _groceryItem = loadedItems;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Failed to load data. Please check your connection.';
        isLoading = false;
      });
    }
  }

  // Method for New Item
  void addItem(BuildContext context) async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => Newitem(),
      ),
    );

    if (newItem == null) return;

    setState(
      () {
        _groceryItem.add(newItem);
      },
    );
  }

  // Method for remove item from list.
  void removeItem(GroceryItem item) async {
    final index = _groceryItem.indexOf(item);
    setState(() {
      _groceryItem.remove(item);
    });

    final url = Uri.https(
      'grocery-b56cb-default-rtdb.asia-southeast1.firebasedatabase.app',
      'Grocery-list/${item.id}.json',
    );

    final scaffoldMessanger = ScaffoldMessenger.of(context);

    final response = await http.delete(url);

    if (response.statusCode >= 404) {
      setState(() {
        _groceryItem.insert(index, item);
      });

      scaffoldMessanger.showSnackBar(
        SnackBar(
          content: Text(
            "Failed to delete item. Please try again.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      scaffoldMessanger.showSnackBar(
        SnackBar(
          content: Text(
            "Item deleted successfully.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.brown,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Center(
        child: Text('No items added yet.'),
      ),
    );

    if (isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItem.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItem.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            onDismissed: (direction) => removeItem(
              _groceryItem[index],
            ),
            key: ValueKey(_groceryItem[index].id),
            child: ListTile(
              title: Text(_groceryItem[index].name),
              leading: Container(
                width: 24,
                height: 24,
                color: _groceryItem[index].category.color,
              ),
              trailing: Text(
                _groceryItem[index].quantity.toString(),
              ),
            ),
          );
        },
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
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
      body: content,
    );
  }
}
