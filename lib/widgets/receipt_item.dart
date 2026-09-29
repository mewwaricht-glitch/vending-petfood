import 'package:flutter/material.dart';
import '../models/product.dart';

class ReceiptItem extends StatelessWidget {
  final CartItem item;

  const ReceiptItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Expanded(child: Text('${item.product.name}  x${item.quantity}', style: const TextStyle(fontSize: 15))),
          Text('${item.lineTotal} บาท', style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
