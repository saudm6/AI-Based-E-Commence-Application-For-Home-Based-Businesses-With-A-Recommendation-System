import 'package:ai_test/data/repositories/product/product_detail_page.dart';
import 'package:flutter/material.dart';
import '../../../features/authentication/models/product_model.dart';

class ProductTile extends StatelessWidget {
  final Product product;

  const ProductTile({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(

            // Go to ProductDetailPage
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Card(
        child: Column(
          children: [

            // Transition
            Hero(
              tag: product.id,
              child: Image.network(
                product.images.first,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(product.name),
          ],
        ),
      ),
    );
  }
}
