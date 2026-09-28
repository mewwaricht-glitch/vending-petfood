import 'package:flutter/material.dart';
import '../models/product.dart';

class MenuService {
  MenuService._();

  static const List<String> categories = [
    'อาหารแมว',
    'อาหารสุนัข',
    'อาหารแฮมสเตอร์',
    'นมแพะ',
  ];

  static const List<Product> dryCatItems = [
    Product(
      id: 'cat_dry_001',
      name: 'Pramy รสปลาทูน่า',
      size: '50 กรัม',
      price: 20,
      imagePath: 'assets/cat/2.png',
      category: 'อาหารแมว',
    ),
    Product(
      id: 'cat_dry_002',
      name: 'Pramy รสปลาแซลมอน',
      size: '50 กรัม',
      price: 20,
      imagePath: 'assets/cat/3.png',
      category: 'อาหารแมว',
    ),
    Product(
      id: 'cat_dry_003',
      name: 'Pramy รสไก่',
      size: '50 กรัม',
      price: 20,
      imagePath: 'assets/cat/5.png',
      category: 'อาหารแมว',
    ),
    Product(
      id: 'cat_dry_004',
      name: 'Buzz Beyond รสปลาทูน่า',
      size: '50 กรัม',
      price: 30,
      imagePath: 'assets/cat/6.png',
      category: 'อาหารแมว',
    ),
    Product(
      id: 'cat_dry_005',
      name: 'Buzz Beyond รสปลาแซลมอน',
      size: '50 กรัม',
      price: 30,
      imagePath: 'assets/cat/7.png',
      category: 'อาหารแมว',
    ),
    Product(
      id: 'cat_dry_006',
      name: 'Buzz Beyond รสปลาแซลมอน ทูน่า และนม',
      size: '50 กรัม',
      price: 30,
      imagePath: 'assets/cat/8.png',
      category: 'อาหารแมว',
    ),
    Product(
      id: 'cat_dry_007',
      name: 'Whiskas แม่และลูกแมว รสปลาทะเล',
      size: '50 กรัม',
      price: 20,
      imagePath: 'assets/cat/9.png',
      category: 'อาหารแมว',
    ),
    Product(
      id: 'cat_dry_008',
      name: 'Whiskas แมวโต รสปลาทูน่าและแซลมอน',
      size: '50 กรัม',
      price: 20,
      imagePath: 'assets/cat/10.png',
      category: 'อาหารแมว',
    ),
    Product(
      id: 'cat_dry_009',
      name: 'Whiskas แม่และลูกแมว รสปลาทูน่าและแซลมอน',
      size: '50 กรัม',
      price: 20,
      imagePath: 'assets/cat/11.png',
      category: 'อาหารแมว',
    ),
    Product(
      id: 'cat_dry_010',
      name: 'Friskies สูตรลูกแมว',
      size: '50 กรัม',
      price: 15,
      imagePath: 'assets/cat/12.png',
      category: 'อาหารแมว',
    ),
    Product(
      id: 'cat_dry_011',
      name: 'Friskies สูตรแมวเลี้ยงในบ้าน',
      size: '50 กรัม',
      price: 15,
      imagePath: 'assets/cat/13.png',
      category: 'อาหารแมว',
    ),
    Product(
      id: 'cat_dry_012',
      name: 'Friskies รสรวมมิตรปลาทะเล',
      size: '50 กรัม',
      price: 15,
      imagePath: 'assets/cat/purple.png',
      category: 'อาหารแมว',
    ),
    Product(
      id: 'cat_dry_013',
      name: 'Friskies รสซีฟู้ด',
      size: '50 กรัม',
      price: 15,
      imagePath: 'assets/cat/15.png',
      category: 'อาหารแมว',
    ),
  ];

  static const List<Product> wetCatItems = [
    Product(
      id: 'cat_wet_001',
      name: 'Kaniva เนื้อปลาทูน่าหน้าหอยเชลล์และกุ้งในน้ำเกรวี่',
      size: '70 กรัม',
      price: 25,
      imagePath: 'assets/cat/17.png',
      category: 'อาหารแมว',
    ),
    Product(
      id: 'cat_wet_002',
      name: 'Kaniva เนื้อปลาทูน่าหน้าเนื้อล็อบสเตอร์ในเยลลี่',
      size: '70 กรัม',
      price: 25,
      imagePath: 'assets/cat/18.png',
      category: 'อาหารแมว',
    ),
    Product(
      id: 'cat_wet_003',
      name: 'Kaniva เนื้อปลาทูน่าและเนื้อไก่ในเยลลี่',
      size: '70 กรัม',
      price: 25,
      imagePath: 'assets/cat/19.png',
      category: 'อาหารแมว',
    ),
    Product(
      id: 'cat_wet_004',
      name: 'Nekko รสปลาทูน่า',
      size: '70 กรัม',
      price: 20,
      imagePath: 'assets/cat/20.png',
      category: 'อาหารแมว',
    ),
    Product(
      id: 'cat_wet_005',
      name: 'Nekko รสปลาทูน่าหน้าเนื้อไก่',
      size: '70 กรัม',
      price: 20,
      imagePath: 'assets/cat/21.png',
      category: 'อาหารแมว',
    ),
    Product(
      id: 'cat_wet_006',
      name: 'Nekko รสปลาทูน่าหน้าปูอัดในน้ำเกรวี่',
      size: '70 กรัม',
      price: 20,
      imagePath: 'assets/cat/23.png',
      category: 'อาหารแมว',
    ),
    Product(
      id: 'cat_wet_007',
      name: 'Nekko รสปลาทูน่าหน้าปลาทรายแดงในน้ำเกรวี่',
      size: '70 กรัม',
      price: 20,
      imagePath: 'assets/cat/24.png',
      category: 'อาหารแมว',
    ),
    Product(
      id: 'cat_wet_008',
      name: 'Nekko รสปลาทูน่าในน้ำเกรวี่',
      size: '70 กรัม',
      price: 20,
      imagePath: 'assets/cat/25.png',
      category: 'อาหารแมว',
    ),
    Product(
      id: 'cat_wet_009',
      name: 'Whiskas ลูกแมว รสปลาทู',
      size: '80 กรัม',
      price: 18,
      imagePath: 'assets/cat/22.png',
      category: 'อาหารแมว',
    ),
  ];

  static const List<Product> dogItems = [
    Product(
      id: 'dog_001',
      name: 'Pedigree รสเนื้อวัวและผัก',
      size: '100 กรัม',
      price: 20,
      imagePath: 'assets/dog/1.png',
      category: 'อาหารสุนัข',
    ),
    Product(
      id: 'dog_002',
      name: 'Kaniva รสเนื้อไก่ ปลาทูน่าและข้าว',
      size: '100 กรัม',
      price: 25,
      imagePath: 'assets/dog/2.png',
      category: 'อาหารสุนัข',
    ),
    Product(
      id: 'dog_003',
      name: 'Pedigree รสเนื้อแกะและผัก',
      size: '100 กรัม',
      price: 20,
      imagePath: 'assets/dog/4.png',
      category: 'อาหารสุนัข',
    ),
    Product(
      id: 'dog_004',
      name: 'Kaniva รสแซลมอน',
      size: '100 กรัม',
      price: 25,
      imagePath: 'assets/dog/9.png',
      category: 'อาหารสุนัข',
    ),
    Product(
      id: 'dog_005',
      name: 'Kaniva รสเนื้อไก่งวง',
      size: '100 กรัม',
      price: 25,
      imagePath: 'assets/dog/10.png',
      category: 'อาหารสุนัข',
    ),
    Product(
      id: 'dog_006',
      name: 'Royal Canin สูตรสุนัขอายุ 7 ปีขึ้นไป',
      size: '100 กรัม',
      price: 30,
      imagePath: 'assets/dog/8.png',
      category: 'อาหารสุนัข',
    ),
  ];

  static const List<Product> milkItems = [
    Product(
      id: 'cat_milk_001',
      name: 'I Love Smart Heart นมแพะสดสเตอริไลส์',
      size: '70 มล.',
      price: 25,
      imagePath: 'assets/cat/4.png',
      category: 'นมแพะ',
    ),
    Product(
      id: 'cat_milk_002',
      name: 'Pramy นมแพะสเตอริไลส์',
      size: '60 มล.',
      price: 20,
      imagePath: 'assets/cat/18.png',
      category: 'นมแพะ',
    ),
  ];

  static const List<Product> hamsterItems = [
    Product(
      id: 'hamster_001',
      name: 'Pedigree Complete & Balanced',
      size: '5 กรัม',
      price: 20,
      imagePath: 'assets/hamster/3.png',
      category: 'อาหารแฮมสเตอร์',
    ),
    Product(
      id: 'hamster_002',
      name: 'Little One With Carob & Yucca',
      size: '5 กรัม',
      price: 15,
      imagePath: 'assets/hamster/5.png',
      category: 'อาหารแฮมสเตอร์',
    ),
    Product(
      id: 'hamster_003',
      name: 'Little One With Meadow & Garden grass seeds',
      size: '5 กรัม',
      price: 15,
      imagePath: 'assets/hamster/6.png',
      category: 'อาหารแฮมสเตอร์',
    ),
  ];

  static List<Product> getProductsByCategory(String category) {
    final allProducts = [
      ...dryCatItems,
      ...wetCatItems,
      ...milkItems,
      ...dogItems,
      ...hamsterItems,
    ];

    return allProducts.where((p) => p.category == category).toList();
  }
}
