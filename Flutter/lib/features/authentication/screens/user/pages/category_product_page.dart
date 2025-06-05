import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../data/repositories/product/product_detail_page.dart';
import '../../../models/product_model.dart';

class CategoryProductsPage extends StatefulWidget {
  final String categoryId;
  const CategoryProductsPage({Key? key, required this.categoryId, required String categoryName}) : super(key: key);

  @override
  _CategoryProductsPageState createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  final List<DocumentSnapshot> _products = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  static const int _limit = 30;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isLoading && _hasMore &&
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _fetchProducts();
    }
  }

  // Fetch products
  Future<void> _fetchProducts() async {
    if (_isLoading) return;
    setState(() { _isLoading = true; });

    Query query = FirebaseFirestore.instance
        .collection('products')
        .where('categoryId', isEqualTo: widget.categoryId)
        .limit(_limit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
      _products.addAll(snapshot.docs);
    }

    if (snapshot.docs.length < _limit) {
      _hasMore = false;
    }

    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryId)),
      body: _products.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        controller: _scrollController,
        itemCount: _products.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _products.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final doc   = _products[index];
          final data = _products[index].data() as Map<String, dynamic>;
          final name = data['productName'] as String? ?? '';
          final desc = data['productDescription'] as String? ?? '';
          final images = (data['productImages'] as List<dynamic>?)?.cast<String>() ?? [];
          final thumbnail = images.isNotEmpty ? images.first : null;
          final priceVal = data['price'];
          final price = priceVal is num ? priceVal.toDouble() : double.tryParse('$priceVal') ?? 0;

          final product = Product(
            id: doc.id,
            name: data['productName'] ?? '',
            description: data['productDescription'] ?? '',
            images:
            (data['productImages'] as List<dynamic>?)
                ?.cast<String>() ??
                [],
            price:
            (data['price'] as num?)?.toDouble() ?? 0.0,
          );

          // Display product info
          return ListTile(
            leading: thumbnail != null
                ? Image.network(thumbnail, width: 60, height: 60, fit: BoxFit.cover)
                : const Icon(Icons.image_not_supported),
            title: Text(name),
            subtitle: Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: Text('OMR ${price.toStringAsFixed(3)}'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (_) => ProductDetailPage(product: product),
              ));
            },
          );
        },
      ),
    );
  }
}