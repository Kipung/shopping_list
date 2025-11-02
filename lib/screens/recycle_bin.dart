import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';

class RecycleBin extends StatefulWidget {
  const RecycleBin({
    super.key,
    required this.deletedItems,
    required this.onRestore,
  });

  final List<GroceryItem> deletedItems;
  final void Function(GroceryItem item) onRestore;

  @override
  State<RecycleBin> createState() => _RecycleBinState();
}

class _RecycleBinState extends State<RecycleBin> {
  late List<GroceryItem>
      _localDeleted; // Local copy to manage state within this screen

  @override
  void initState() {
    super.initState();
    // make a local copy so we can remove items from the screen immediately
    _localDeleted = List.from(widget.deletedItems);
  }

  void _handleRestore(GroceryItem item) {
    // 1. tell parent to restore the item
    widget.onRestore(item);
    // 2. update this screen immediately
    setState(() {
      _localDeleted.removeWhere((g) => g.id == item.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recycle Bin')),
      body: _localDeleted.isEmpty
          ? const Center(
              child: Text('No deleted items.'),
            )
          : ListView.builder(
              itemCount: _localDeleted.length,
              itemBuilder: (ctx, index) {
                final item = _localDeleted[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('Quantity: ${item.quantity}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.restore),
                    onPressed: () {
                      _handleRestore(item);
                    },
                  ),
                );
              },
            ),
    );
  }
}
