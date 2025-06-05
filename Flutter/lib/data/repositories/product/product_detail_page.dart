import 'package:flutter/material.dart';
import '../../../features/authentication/models/product_model.dart';
import '../../../features/authentication/screens/user/screens/recommended_products.dart';
import '../../../features/personalization/color_variants_picker.dart';
import '../../../features/store/add_to_cart.dart';
import '../../../features/store/store_detail_page.dart';
import 'full_screen_image_viewer.dart';
import 'like_button.dart';
import '../../../features/store/fetch_store_info.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _currentImageIndex = 0;
  Color? _selectedVariant;
  late final String _priceText;

  @override
  void initState() {
    super.initState();
    _priceText = 'OMR ${widget.product.price.toStringAsFixed(3)}';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      appBar: AppBar(
        title: Text(p.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Image Carousel
            if (p.images.isNotEmpty) ...[
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: p.images.length,
                  controller: PageController(initialPage: _currentImageIndex),
                  onPageChanged: (i) => setState(() => _currentImageIndex = i),
                  itemBuilder: (context, i) => GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenImageViewer(
                            images: p.images,
                            initialIndex: i,
                            heroTagPrefix: p.id,
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: '${p.id}-image-$i',
                      child: Image.network(p.images[i], fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(p.images.length, (i) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    width: _currentImageIndex == i ? 12 : 8,
                    height: _currentImageIndex == i ? 12 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == i
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                  );
                }),
              ),
            ] else ...[

              // If no images use placeholder
              Container(
                height: 300,
                color: Colors.black12,
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 64),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Like and Store Link Section
            FutureBuilder<Map<String, String?>>(
              future: fetchStoreInfo(widget.product.id),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done ||
                    snap.data == null) {
                  return const SizedBox();
                }
                final storeName = snap.data!['name'] ?? '';
                return LikeButton(
                  productId: widget.product.id,
                  storeName: storeName,
                  productTitle: widget.product.name,
                  price: widget.product.price,
                );
              },
            ),

            const SizedBox(height: 16),

            // Store name, price, description etc
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),

                  // / Navigate to store details
                  FutureBuilder<Map<String, String?>>(
                    future: fetchStoreInfo(widget.product.id),
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done ||
                          snap.data == null) {
                        return const SizedBox();
                      }
                      final info = snap.data!;
                      final cid = info['id'];
                      final storeName = info['name'];
                      if (cid == null || storeName == null) {
                        return const SizedBox();
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StoreDetailsPage(
                                sellerId: cid,
                                storeName: storeName,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          storeName,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // Price text
                  Text(_priceText,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // Product description
                  Text(p.description),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Color variants
            ColorVariantPicker(
              productId: widget.product.id,
              initialColor: _selectedVariant,
              onColorSelected: (color) {
                setState(() {
                  _selectedVariant = color;
                });
              },
            ),

            const SizedBox(height: 24),

            // Recommendations section
            RecommendedProducts(productId: widget.product.id),

            const SizedBox(height: 24),

            // Add to cart button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await addToCart(
                        context: context,
                        productId: widget.product.id,
                        productImages: widget.product.images,
                        productName: widget.product.name,
                        productPrice: widget.product.price,
                        selectedVariant: _selectedVariant);
                  },
                  child: const Text('Add to Cart'),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
