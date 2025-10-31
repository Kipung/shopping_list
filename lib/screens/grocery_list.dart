import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:shopping_list/screens/recycle_bin.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  List<GroceryItem> _filteredItems = [];
  List<GroceryItem> _deletedItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'proj-315a8-default-rtdb.firebaseio.com', 'shopping-list.json');

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later.';
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        _groceryItems = loadedItems;
        _filteredItems = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong! Please try again later.';
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
      _filteredItems = List.from(_groceryItems);
    });
  }

  void _removeItem(GroceryItem item) async {
    setState(() {
      _groceryItems.removeWhere((g) => g.id == item.id);
      _filteredItems.removeWhere((g) => g.id == item.id);

      _deletedItems.add(item);
    });

    final url = Uri.https('proj-315a8-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      // Optional: Show error message
      setState(() {
        _groceryItems.add(item);
        _filteredItems = List.from(_groceryItems);
        _deletedItems.removeWhere((g) => g.id == item.id);
      });
    }
  }

  void _restoreItem(GroceryItem item) {
    setState(() {
      // back to main list
      _groceryItems.add(item);
      _filteredItems = List.from(_groceryItems);

      // remove from bin
      _deletedItems.removeWhere((g) => g.id == item.id);

      // push back to Firebase
      final url = Uri.https('proj-315a8-default-rtdb.firebaseio.com',
          'shopping-list/${item.id}.json');

      http.put(url,
          body: json.encode({
            'name': item.name,
            'quantity': item.quantity,
            'category': item.category.title,
          }));
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items added yet.'));

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_filteredItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _filteredItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_filteredItems[index]);
          },
          key: ValueKey(_filteredItems[index].id),
          child: ListTile(
            title: Text(_filteredItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _filteredItems[index].category.color,
            ),
            trailing: Text(
              _filteredItems[index].quantity.toString(),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(child: Text(_error!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                setState(() {
                  _filteredItems = _groceryItems
                      .where((item) =>
                          item.name.toLowerCase().contains(query.toLowerCase()))
                      .toList();
                });
              },
            ),
          ),
          Expanded(child: content),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 30, 28, 40),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => RecycleBin(
                          deletedItems: _deletedItems,
                          onRestore: _restoreItem,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
