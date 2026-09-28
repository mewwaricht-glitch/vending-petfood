import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String size;
  final int price;
  final String imagePath;
  final String category;

  /// จำนวนสินค้าคงเหลือในตู้ (ปรับได้ทีละชิ้นใน services/menu_service.dart ถ้าต้องการ)
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

/// สินค้า 1 รายการที่อยู่ในตะกร้า พร้อมจำนวนที่ลูกค้าเลือก
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  /// ราคารวมของรายการนี้ = ราคาต่อชิ้น x จำนวน
  int get lineTotal => product.price * quantity;
}
