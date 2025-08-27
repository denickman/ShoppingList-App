import 'package:flutter/material.dart';
import 'package:shoppinglist/data/categories.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a new item')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(label: Text('Name')),
                validator: (value) {
                  return 'Demo...';
                },
              ), // instead of TextField

              Row(
                crossAxisAlignment: CrossAxisAlignment.end, // for elements alignment 
                children: [
                  Expanded(
                    child: TextFormField( // unconstrained horizontally !!!! CAREFUL
                      decoration: const InputDecoration(label: Text('Quantity')),
                      initialValue: '1',
                    ),
                  ),
                  const SizedBox(width: 24),

                  Expanded(
                    child: DropdownButtonFormField(  // unconstrained horizontally !!!! CAREFUL
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children:[
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 8),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                    
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
