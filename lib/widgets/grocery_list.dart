import 'dart:convert'; // for json
import 'package:flutter/material.dart';
import 'package:shoppinglist/data/categories.dart';
// import 'package:shoppinglist/data/dummy_items.dart';
import 'package:shoppinglist/widgets/new_item.dart';
import 'package:shoppinglist/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  // ====== Properties ======
  List<GroceryItem> _groceyItems = [];
  var _isLoading = true;
  String? _error;

  // ====== Lifecycle ======
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items added yet!'));

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_groceyItems.isNotEmpty) {
      content = ListView.builder(
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
    }

    if (_error != null) {
      content = Center(child: Text(_error!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: content,
    );
  }

  // ====== Methods ======

  void _addItem() async {
    // option # 1 - Without BACKEND
    /*
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
  */

    // option # 2 - With BACKEND

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

  void _loadItems() async {
    final url = Uri.https(
      'shoppinglistflutter-e661d-default-rtdb.firebaseio.com',
      'shlist.json',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later';
        });
      }

      if (response.body == "null") {
        setState(() {
          _isLoading = false;
        });
        return;
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

      setState(() {
        _groceyItems = loadedItemList;
        _isLoading = false;
      });
    } catch (error) {
      // throw Exception('An error occured!');
       setState(() {
          _error = 'Failed to fetch data. Please try again later';
        });
    }
  }
}
