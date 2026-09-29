import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_grid_item.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final int Function(Product product) inCartQty;
  final void Function(Product product) onToggle;

  const ProductGrid({
    super.key,
    required this.products,
    required this.inCartQty,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final qty = inCartQty(product);
          final remaining = product.stock - qty;

          return SizedBox(
            width: 190,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ProductGridItem(
                product: product,
                selected: qty > 0,
                remaining: remaining,
                onTap: () => onToggle(product),
              ),
            ),
          );
        },
      ),
    );
  }
}
