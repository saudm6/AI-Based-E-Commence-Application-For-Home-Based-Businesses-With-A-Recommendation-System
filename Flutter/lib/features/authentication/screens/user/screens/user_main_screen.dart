import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../../common/widgets/welcome_back_title.dart';
import '../../../../../data/repositories/product/product_detail_page.dart';
import '../../../models/product_model.dart';
import '../controllers/random_categories.dart';
import '../pages/category_page.dart';
import '../pages/category_product_page.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({Key? key}) : super(key: key);

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _scrollController = ScrollController();

  // Banner
  final _pageController = PageController(viewportFraction: 1);
  Timer? _bannerTimer;
  int _currentBannerPage = 0;
  static const int _bannerCount   = 2;
  static const _bannerInterval    = Duration(seconds: 5);

  // Products
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _productDocs = [];
  bool _isLoadingProducts = false;
  bool _hasMoreProducts   = true;
  DocumentSnapshot? _lastProductDoc;
  static const int _productBatch = 50;

  // Categories
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _categoryDocs = [];


  @override
  void initState() {
    super.initState();

    _loadNextProductBatch();
    _loadCategories();

    _scrollController.addListener(_onScroll);

    _bannerTimer = Timer.periodic(_bannerInterval, (_) {
      _currentBannerPage = (_currentBannerPage + 1) % _bannerCount;
      _pageController.animateToPage(
        _currentBannerPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingProducts &&
        _hasMoreProducts) {
      _loadNextProductBatch();
    }
  }

  // Load data
  Future<void> _loadNextProductBatch() async {
    if (_isLoadingProducts) return;
    setState(() => _isLoadingProducts = true);

    Query<Map<String, dynamic>> q = _firestore
        .collection('products')
        .orderBy(FieldPath.documentId)
        .limit(_productBatch);

    if (_lastProductDoc != null) q = q.startAfterDocument(_lastProductDoc!);

    final snap = await q.get();
    if (snap.docs.length < _productBatch) _hasMoreProducts = false;

    if (snap.docs.isNotEmpty) {
      _lastProductDoc = snap.docs.last;
      _productDocs.addAll(snap.docs);
    }

    setState(() => _isLoadingProducts = false);
  }

  Future<void> _loadCategories() async {
    final snap = await _firestore.collection('categories').get();
    if (snap.docs.isNotEmpty) {
      _categoryDocs.addAll(snap.docs);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageHeight = MediaQuery.of(context).size.width / 2.5;

    // Select random product
    final rnd = Random();
    final Map<String, QueryDocumentSnapshot<Map<String, dynamic>>> onePerCat = {};
    for (var doc in _productDocs) {
      final cat = doc.data()['categoryId'] as String? ?? '';
      if (!onePerCat.containsKey(cat) || rnd.nextBool()) onePerCat[cat] = doc;
    }
    final displayDocs = onePerCat.values.toList();

    return Scaffold(
      appBar: AppBar(title: welcomeBackTitle(context)),
      body: _productDocs.isEmpty && _isLoadingProducts
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Banner
          SliverToBoxAdapter(
            child: SizedBox(
              width: 330,
              height: imageHeight,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CategoryPage()),
                    ),
                    child: Image.network(
                      'https://www.getmarvia.com/hubfs/OG-local%20campaigns.png',
                      fit: BoxFit.cover,
                      width: 330,
                      height: imageHeight,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CategoryPage()),
                    ),
                    child: Image.network(
                      'https://thumbs.dreamstime.com/b/red-color-inserted-label-word-category-gray-background-218750007.jpg?w=992',
                      fit: BoxFit.cover,
                      width: 330,
                      height: imageHeight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Random Category
          const RandomCategories(),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Product grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.7,
              ),
              delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _buildProductTile(_toProduct(displayDocs[i])),
                childCount: displayDocs.length,
              ),
            ),
          ),

          if (_isLoadingProducts)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  // Category widget
  Widget _buildCategoryTile(
      BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final String name = (data['name'] ?? '').toString();
    final String? thumb = data['thumbnailUrl'] as String?;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CategoryProductsPage(categoryId: doc.id, categoryName: name),
        ),
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (thumb != null && thumb.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  thumb,
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                ),
              )
            else
              CircleAvatar(
                radius: 35,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Product widget
  Widget _buildProductTile(Product product) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: product.images.isNotEmpty
                  ? ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8)),
                child: Image.network(
                  product.images.first,
                  fit: BoxFit.cover,
                ),
              )
                  : const Icon(Icons.image_not_supported,
                  size: 48, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'OMR ${product.price.toStringAsFixed(3)}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Convert firestore doc info
  Product _toProduct(
      QueryDocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data();
    return Product(
      id: snap.id,
      name: data['productName'] ?? '',
      description: data['productDescription'] ?? '',
      images: (data['productImages'] as List<dynamic>?)?.cast<String>() ?? [],
      price: (data['price'] is num
          ? (data['price'] as num).toDouble()
          : double.tryParse('${data['price']}')) ??
          0.0,
    );
  }
}