import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clerk_flutter/clerk_flutter.dart';

/// Shopping list page that displays user's grocery lists.
class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  Future<void> updateShoppingListIngredients(
    DocumentReference docRef,
    List<String> ingredients,
  ) async {
    await docRef.update({'List': ingredients});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping List')),
      body: ClerkAuthBuilder(
        signedInBuilder: (context, authState) {
          final user = authState.user;
          if (user == null) {
            return const Center(
              child: Text('Please sign in to view your shopping list.'),
            );
          }
          final userId = user.id;
          return StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('Shopping')
                    .where(
                      'userid',
                      isEqualTo: FirebaseFirestore.instance.doc(
                        '/user/$userId',
                      ),
                    )
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                );
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Center(
                  child: Text('No recipes in your shopping list.'),
                );
              }
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final recipeName = doc.id;
                  final ingredients = List<String>.from(doc['List'] ?? []);
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    elevation: 0,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          recipeName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.green,
                                          ),
                                          tooltip: 'Edit List',
                                          onPressed: () async {
                                            await showDialog(
                                              context: context,
                                              builder:
                                                  (context) =>
                                                      _EditShoppingListDialog(
                                                        docRef: doc.reference,
                                                        initialIngredients:
                                                            ingredients,
                                                      ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ...ingredients.map(
                                (ingredient) => _IngredientCheckbox(
                                  recipeDoc: doc.reference,
                                  ingredient: ingredient,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete List',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Delete Shopping List'),
                                      content: const Text(
                                        'Are you sure you want to delete this shopping list?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirm == true) {
                                await doc.reference.delete();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
        signedOutBuilder:
            (context, _) => const Center(
              child: Text('Please sign in to view your shopping list.'),
            ),
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            backgroundColor: Colors.green[700],
            elevation: 0,
            highlightElevation: 0,
            disabledElevation: 0,
            onPressed: () async {
              final authState = ClerkAuth.of(context);
              final user = authState.user;
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please sign in to add a shopping list.'),
                  ),
                );
                return;
              }
              final result = await showDialog(
                context: context,
                builder: (context) => const _EditShoppingListDialog(),
              );
              if (result != null &&
                  result is Map &&
                  result['name'] != null &&
                  (result['ingredients'] as List).isNotEmpty) {
                final userId = user.id;
                final listName = result['name'] as String;
                final ingredients = List<String>.from(
                  result['ingredients'] as List,
                );
                await FirebaseFirestore.instance
                    .collection('Shopping')
                    .doc(listName)
                    .set({
                      'List': ingredients,
                      'userid': FirebaseFirestore.instance.doc('/user/$userId'),
                    });
              }
            },
            child: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Create Shopping List',
          );
        },
      ),
    );
  }
}

class _EditShoppingListDialog extends StatefulWidget {
  const _EditShoppingListDialog({this.docRef, this.initialIngredients});

  final DocumentReference? docRef;
  final List<String>? initialIngredients;

  @override
  State<_EditShoppingListDialog> createState() =>
      _EditShoppingListDialogState();
}

class _EditShoppingListDialogState extends State<_EditShoppingListDialog> {
  late List<String> ingredients;
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ingredients = List<String>.from(widget.initialIngredients ?? []);
    if (widget.docRef == null) {
      _nameController.text = '';
    }
  }

  void _addIngredient(String value) {
    if (value.trim().isNotEmpty) {
      setState(() {
        ingredients.add(value.trim());
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.docRef == null ? 'Create Shopping List' : 'Edit Shopping List',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.docRef == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'List Name'),
              ),
            ),
          ...ingredients.map(
            (ingredient) => ListTile(
              title: Text(ingredient),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    ingredients.remove(ingredient);
                  });
                },
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Add Ingredient',
                  ),
                  onSubmitted: (value) {
                    _addIngredient(value);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.green),
                onPressed: () {
                  _addIngredient(_controller.text);
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (widget.docRef != null) {
              try {
                await widget.docRef!.update({'List': ingredients});
              } catch (e) {
                debugPrint('Error updating shopping list: $e');
              }
              Navigator.pop(context, ingredients);
            } else {
              final listName = _nameController.text.trim();
              if (listName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a list name.')),
                );
                return;
              }
              Navigator.pop(context, {
                'name': listName,
                'ingredients': ingredients,
              });
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _IngredientCheckbox extends StatefulWidget {
  const _IngredientCheckbox({
    required this.recipeDoc,
    required this.ingredient,
  });

  final DocumentReference recipeDoc;
  final String ingredient;

  @override
  State<_IngredientCheckbox> createState() => _IngredientCheckboxState();
}

class _IngredientCheckboxState extends State<_IngredientCheckbox> {
  bool checked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: checked,
          onChanged: (value) {
            setState(() {
              checked = value ?? false;
            });
          },
          activeColor: Colors.green,
        ),
        Expanded(child: Text(widget.ingredient)),
      ],
    );
  }
}
