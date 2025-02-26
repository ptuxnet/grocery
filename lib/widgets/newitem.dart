import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groceryapp/data/categories.dart';
import 'package:groceryapp/models/category.dart';
import 'package:http/http.dart' as http;

class Newitem extends StatefulWidget {
  const Newitem({super.key});

  @override
  State<Newitem> createState() => _NewitemState();
}

class _NewitemState extends State<Newitem> {
  final _formkey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.fruit]!;

  void _saveItem() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      final url = Uri.https(
          'grocery-b56cb-default-rtdb.asia-southeast1.firebasedatabase.app',
          'Grocery-list.json');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': _selectedCategory.title,
          },
        ),
      );

      print(response.body);
      print(response.statusCode);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('ADD NEW ITEM'),
      ),
      body: Padding(
          padding: EdgeInsets.all(12),
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(
                    label: Text('Name'),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return 'Must be between 1 and 50 characters';
                    }

                    return null;
                  },
                  onSaved: (value) {
                    // if (value == null) {
                    //   return;
                    // }
                    _enteredName = value!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          label: Text('Quantity'),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Must be a valid, positive number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredQuantity = int.parse(value!);
                        },
                        initialValue: '1',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: _selectedCategory,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                                value: category.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: category.value.color,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(category.value.title)
                                  ],
                                ))
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        _formkey.currentState!.reset();
                      },
                      child: const Text('Reset'),
                    ),
                    ElevatedButton(
                      onPressed: _saveItem,
                      child: Text('Add Item'),
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }
}
