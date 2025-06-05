import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../data/repositories/product/product_detail_page.dart';
import '../../../models/product_model.dart';

class SearchPageUser extends StatefulWidget {
  const SearchPageUser({Key? key}) : super(key: key);

  @override
  State<SearchPageUser> createState() => _SearchPageUserState();
}

class _SearchPageUserState extends State<SearchPageUser> {
  final _searchCtl = TextEditingController();
  String _term = '';

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  void _startSearch() =>
      setState(() => _term = _searchCtl.text.trim().toLowerCase());

  // Build query
  Query<Map<String, dynamic>> _buildQuery(String term) {
    if (term.isEmpty) {
      return FirebaseFirestore.instance.collection('products').limit(0);
    }

    return FirebaseFirestore.instance
        .collection('products')
        .orderBy('productNameLower')
        .startAt([term])
        .endAt([term + '\uf8ff'])
        .limit(12);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Products')),
      body: Column(
        children: [

          // Search field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchCtl,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _startSearch(),
              decoration: InputDecoration(
                hintText: 'Search by product name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _startSearch,
                ),
              ),
            ),
          ),

          Expanded(
            child: _term.isEmpty
                ? const Center(
              child: Text('Enter a search term and press Search'),
            )
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _buildQuery(_term).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('No products found'));
                }

                // Display results
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, idx) {
                    final data = docs[idx].data();

                    final product = Product(
                      id: docs[idx].id,
                      name: data['productName'] ?? '',
                      description: data['productDescription'] ?? '',
                      images:
                      (data['productImages'] as List<dynamic>?)
                          ?.cast<String>() ??
                          [],
                      price:
                      (data['price'] as num?)?.toDouble() ?? 0.0,
                    );

                    // Display details like price, name etc
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                        'OMR ${product.price.toStringAsFixed(3)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      trailing: product.images.isNotEmpty
                          ? Image.network(
                        product.images.first,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                          : const Icon(Icons.image_not_supported),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailPage(product: product),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}