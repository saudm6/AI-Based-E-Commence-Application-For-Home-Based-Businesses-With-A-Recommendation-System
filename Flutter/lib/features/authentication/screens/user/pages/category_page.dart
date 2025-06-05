import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'category_product_page.dart';

// Lists all categories with image and name
class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Category')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('product_categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No categories found'));
          }

          // Scrollable list of categories
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final id = doc.id;
              final data = doc.data();
              final name = data['categoryName'] as String? ?? id;
              final imgUrl = data['categoryImg'] as String?;
              return ListTile(
                leading: imgUrl != null
                    ? Image.network(imgUrl, width: 40, height: 40, fit: BoxFit.cover)
                    : const Icon(Icons.category),
                title: Text(name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {

                  // Go to category page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryProductsPage(
                        categoryId: id,
                        categoryName: name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
