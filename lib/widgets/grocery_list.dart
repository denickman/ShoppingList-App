import 'package:flutter/material.dart';
// import 'package:shoppinglist/data/dummy_items.dart';
import 'package:shoppinglist/widgets/new_item.dart';
import 'package:shoppinglist/models/grocery_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceyItems = [];

  void _addItem() async {
    // push always yields a future that hold a data that maybe return from the pushed screen
    final newItem = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => const NewItem()));

    if (newItem == null) {
      // in case we just pop the NewItem screen without any changes
      return;
    }

    setState(() {
      _groceyItems.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: ListView.builder(
        itemCount: _groceyItems.length,
        itemBuilder: (ctx, index) => ListTile(
          title: Text(_groceyItems[index].name),
          leading: Container(
            width: 24,
            height: 24,
            color: _groceyItems[index].category.color,
          ),
          trailing: Text(_groceyItems[index].quantity.toString()),
        ),
      ),
    );
  }
}
