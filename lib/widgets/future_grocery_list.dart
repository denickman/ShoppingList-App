import 'dart:convert'; // for json
import 'package:flutter/material.dart';
import 'package:shoppinglist/data/categories.dart';
// import 'package:shoppinglist/data/dummy_items.dart';
import 'package:shoppinglist/widgets/new_item.dart';
import 'package:shoppinglist/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class FutureGroceryList extends StatefulWidget {
  const FutureGroceryList({super.key});

  @override
  State<FutureGroceryList> createState() => _FutureGroceryListState();
}

class _FutureGroceryListState extends State<FutureGroceryList> {
  // ====== Properties ======
  List<GroceryItem> _groceyItems = [];
  late Future<List<GroceryItem>> _loadedItems;
  String? _error;

  // ====== Lifecycle ======
  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: FutureBuilder(
        future: _loadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            Center(child: Text(snapshot.error.toString()));
          }

          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No items added yet!'));
          }

          return ListView.builder(
            itemCount: _groceyItems.length,
            itemBuilder: (ctx, index) => Dismissible(
              onDismissed: (direction) {
                _removeItem(_groceyItems[index]);
              },
              key: ValueKey(_groceyItems[index].id),
              child: ListTile(
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
        },
      ),
    );
  }

  // ====== Methods ======

  void _addItem() async {
    final newItem = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => const NewItem()));

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceyItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceyItems.indexOf(item);

    setState(() {
      _groceyItems.remove(item);
    });

    // send delete request
    final url = Uri.https(
      'shoppinglistflutter-e661d-default-rtdb.firebaseio.com',
      'shlist/${item.id}.json',
    );

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceyItems.insert(index, item);
      });
    }
  }

  // since `async` always return a Future, we must return a Future
  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https(
      'shoppinglistflutter-e661d-default-rtdb.firebaseio.com',
      'shlist.json',
    );

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception("Failed to fetch grocery items. Please try again later.");
    }

    if (response.body == "null") {
      return [];
    }

    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItemList = [];

    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
            (catItem) => catItem.value.title == item.value['category'],
          )
          .value;

      loadedItemList.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }

    return loadedItemList;
  }
}
