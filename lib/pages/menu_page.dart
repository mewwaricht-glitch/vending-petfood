import 'dart:async';
import 'package:flutter/material.dart';
import '../services/menu_service.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../widgets/product_grid_item.dart';
import '../widgets/cart_bar.dart';
import 'payment_page.dart';

/// จำนวนวินาทีที่ปล่อยให้ไม่มีการแตะหน้าจอ ก่อนตู้จะเคลียร์ตะกร้าอัตโนมัติ
const int kIdleSecondsTotal = 30;

/// หน้าเมนูหลักของตู้ — จุดที่ลูกค้าเลือกหมวดหมู่, เลือกสินค้าใส่ตะกร้า,
/// และกดชำระเงิน เป็นหน้าจอแรกที่แอปแสดง (ดู main.dart)
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _selectedCategory = MenuService.categories[0]; // ค่าเริ่มต้น: อาหารแมว
  final List<CartItem> _cart = [];
  Timer? _idleTimer;
  int _idleSecondsLeft = kIdleSecondsTotal;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  // ---- การจัดการ idle timer / รีเซ็ตอัตโนมัติเมื่อไม่มีการใช้งาน --------

  /// เรียกทุกครั้งที่มีการโต้ตอบกับหน้าจอ เพื่อรีเซ็ตนาฬิกานับถอยหลัง
  void _touch() {
    _idleSecondsLeft = kIdleSecondsTotal;
    if (_cart.isNotEmpty && _idleTimer == null) {
      _startIdleTimer();
    }
  }

  void _startIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _idleSecondsLeft -= 1;
        if (_idleSecondsLeft <= 0) {
          timer.cancel();
          _idleTimer = null;
          _resetOnTimeout();
        }
      });
    });
  }

  void _stopIdleTimerIfCartEmpty() {
    if (_cart.isEmpty) {
      _idleTimer?.cancel();
      _idleTimer = null;
      _idleSecondsLeft = kIdleSecondsTotal;
    }
  }

  // หมดเวลาขณะที่ลูกค้ายังเลือกสินค้าอยู่: ล้างตะกร้าทันทีแล้วกลับไป
  // หน้าเมนูเริ่มต้น (ตู้นี้ไม่มีหน้าต้อนรับให้เด้งกลับไปแล้ว — หน้านี้
  // คือหน้าแรกของทั้งแอป)
  void _resetOnTimeout() {
    setState(() {
      _cart.clear();
      _selectedCategory = MenuService.categories[0];
      _idleSecondsLeft = kIdleSecondsTotal;
    });
  }

  // ---- การแก้ไขตะกร้าสินค้า -----------------------------------------

  void _selectCategory(String category) {
    setState(() => _selectedCategory = category);
    _touch();
  }

  /// เพิ่มสินค้าลงตะกร้า (หรือเพิ่มจำนวนถ้ามีอยู่แล้ว) เมื่อแตะที่การ์ดสินค้า
  void _toggleProduct(Product product) {
    setState(() {
      final existingIndex = _cart.indexWhere((c) => c.product.id == product.id);
      if (existingIndex >= 0) {
        final item = _cart[existingIndex];
        if (item.quantity < product.stock) item.quantity += 1;
      } else if (product.stock > 0) {
        _cart.add(CartItem(product: product));
      }
    });
    _touch();
  }

  /// ปรับจำนวนสินค้าในตะกร้าทีละ 1 (delta = +1 เพิ่ม, -1 ลด)
  void _changeQty(CartItem item, int delta) {
    setState(() {
      final newQty = item.quantity + delta;
      if (newQty <= 0) {
        _cart.remove(item);
      } else if (newQty <= item.product.stock) {
        item.quantity = newQty;
      }
      _stopIdleTimerIfCartEmpty();
    });
    _touch();
  }

  void _removeItem(CartItem item) {
    setState(() {
      _cart.remove(item);
      _stopIdleTimerIfCartEmpty();
    });
    _touch();
  }

  void _clearAll() {
    setState(() {
      _cart.clear();
      _stopIdleTimerIfCartEmpty();
    });
  }

  /// เปิดหน้าชำระเงินและรอผลลัพธ์กลับมา
  Future<void> _checkout() async {
    _idleTimer?.cancel();
    _idleTimer = null;

    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PaymentPage(items: List.of(_cart))),
    );

    if (!mounted) return;

    if (paid == true) {
      // PaymentPage -> ReceiptPage จะปิดตัวเองย้อนกลับมาที่นี่โดยอัตโนมัติ
      // แค่ล้างตะกร้าตอนนี้เพราะคำสั่งซื้อเสร็จสมบูรณ์แล้ว
      setState(() => _cart.clear());
    } else {
      // ผู้ใช้กดยกเลิกการชำระเงิน กลับมาเลือกสินค้าต่อได้
      _touch();
    }
  }

  int _inCartQty(Product product) {
    return _cart
        .firstWhere(
          (c) => c.product.id == product.id,
          orElse: () => CartItem(product: product, quantity: 0),
        )
        .quantity;
  }

  // ---- ส่วนสร้าง UI -----------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _touch,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildCategoryTabs(),
              Expanded(child: _buildBody()),
              const SizedBox(height: 4),
              CartBar(
                items: _cart,
                idleSecondsLeft: _idleSecondsLeft,
                onClearAll: _clearAll,
                onCheckout: _checkout,
                onChangeQty: _changeQty,
                onRemove: _removeItem,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    // อาหารแมวมีแยกเม็ด/เปียกอยู่แล้วในข้อมูล — แสดงเป็น 2 หัวข้อ
    // แยกกันตามดีไซน์ต้นแบบ หมวดหมู่อื่นแสดงเป็นกริดเดียวตามปกติ
    if (_selectedCategory == 'อาหารแมว') {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          _sectionTitle('อาหารเม็ด'),
          const SizedBox(height: 10),
          _buildProductGrid(MenuService.dryCatItems),
          const SizedBox(height: 24),
          _sectionTitle('อาหารเปียก'),
          const SizedBox(height: 10),
          _buildProductGrid(MenuService.wetCatItems),
          const SizedBox(height: 12),
        ],
      );
    }

    final products = MenuService.getProductsByCategory(_selectedCategory);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        _buildProductGrid(products),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark),
    );
  }

  /// กริดสินค้าที่เลื่อนแนวนอนได้ ใช้ซ้ำทั้งในโหมดอาหารแมว (2 แถว) และ
  /// หมวดหมู่อื่น (1 แถว)
  Widget _buildProductGrid(List<Product> products) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final inCartQty = _inCartQty(product);
          final remaining = product.stock - inCartQty;

          return SizedBox(
            width: 190,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ProductGridItem(
                product: product,
                selected: inCartQty > 0,
                remaining: remaining,
                onTap: () => _toggleProduct(product),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Center(
        child: Text(
          'PET FOOD',
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: AppColors.dark,
              letterSpacing: 1),
        ),
      ),
    );
  }

  /// แท็บหมวดหมู่สินค้าที่เลื่อนดูได้ในแนวนอน ด้านบนของหน้าเมนู
  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 50,
      child: Center(
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: MenuService.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 24),
          itemBuilder: (context, index) {
            final category = MenuService.categories[index];
            final selected = category == _selectedCategory;

            return GestureDetector(
              onTap: () => _selectCategory(category),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected ? AppColors.apples : Colors.grey,
                  ),
                  child: Text(category),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
