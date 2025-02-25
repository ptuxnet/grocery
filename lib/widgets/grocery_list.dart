import 'package:flutter/material.dart';
import 'package:groceryapp/models/grocery_item.dart';
import 'package:groceryapp/widgets/newitem.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItem = [];

  // Method for New Item
  void addItem(BuildContext context) async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => Newitem(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItem.add(newItem);
    });
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
