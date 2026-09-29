import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String size;
  final int price;
  final String imagePath;
  final String category;
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.size,
    required this.price,
    required this.imagePath,
    required this.category,
    this.stock = 10,
  });
}

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
  int get lineTotal => product.price * quantity;
}
