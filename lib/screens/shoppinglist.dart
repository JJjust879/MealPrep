import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'additem.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final String userId =
      'demoUser'; // Replace with real user ID after Clerk integration

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping List')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('shopping_lists')
                .doc(userId)
                .collection('items')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No items. Tap + to add.'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final item = docs[index];
              return Dismissible(
                key: Key(item.id),
                background: Container(color: Colors.green[100]),
                onDismissed: (_) async {
                  await item.reference.delete();
                },
                child: ListTile(
                  title: Text(item['name'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await item.reference.delete();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[100],
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddItemPage()),
          );
          if (result is String && result.trim().isNotEmpty) {
            await FirebaseFirestore.instance
                .collection('shopping_lists')
                .doc(userId)
                .collection('items')
                .add({
                  'name': result.trim(),
                  'createdAt': FieldValue.serverTimestamp(),
                });
          }
        },
        child: const Icon(Icons.add, color: Color.fromARGB(255, 28, 122, 34)),
        tooltip: 'Add Item',
      ),
    );
  }
}
