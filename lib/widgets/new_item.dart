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
  /*
GlobalKey<T> простыми словами
Это уникальный ключ, который виден всему приложению, а не только родителю.
Позволяет обращаться к состоянию виджета (State) извне его класса.
Особенно полезно для форм, списков, навигации, когда нужно вызвать метод виджета напрямую.
GlobalKey<FormState> — это уникальный «ярлык» на форму, который можно хранить 
в любом месте, например, в родительском виджете.

2️⃣ Что делает validate() in Form
Проверяет все TextFormField и другие поля формы, у которых есть validator.
Вызывает validator каждого поля и проверяет, вернул ли он null (валидно) или строку ошибки (невалидно).
Возвращает:
true — если все поля прошли проверку
false — если хотя бы одно поле вернуло ошибку


✅ Эффект: key: _formKey,
Введённый текст, выбранные значения, ошибки валидации — всё сохраняется при перерисовке.
Без ключа Form и TextFormField могли бы сброситься, потому что Flutter создаст новый State.

*/
  final _formKey = GlobalKey<FormState>();

  void _saveItem() {
    //currentState - это ссылка на текущее состояние формы (FormState), связанное с этим ключом.
    // _formKey.currentState!.validate();  // проверить все поля
    // _formKey.currentState!.save();      // вызвать onSaved для всех полей
    // _formKey.currentState!.reset();     // сбросить форму
    _formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a new item')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey, // <- ключ гарантирует сохранение состояния
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(label: Text('Name')),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters.';
                  }
                  return null; // indeed a valid input value here
                },
              ), // instead of TextField

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end, // for elements alignment
                children: [
                  Expanded(
                    child: TextFormField(
                      // unconstrained horizontally !!!! CAREFUL
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: '1',
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be a valid positive logic.';
                        }
                        return null; // indeed a valid input value here
                      },
                    ),
                  ),
                  const SizedBox(width: 24),

                  Expanded(
                    child: DropdownButtonFormField(
                      // unconstrained horizontally !!!! CAREFUL
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
                                const SizedBox(width: 8),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () {}, child: const Text("Reset")),

                  ElevatedButton(
                    onPressed: _saveItem,
                    child: const Text("Add item"),
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
