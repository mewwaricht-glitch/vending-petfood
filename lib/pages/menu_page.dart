import 'dart:async';
import 'package:flutter/material.dart';
import '../services/menu_service.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../widgets/category_tab.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_bar.dart';
import 'payment_page.dart';

const int IdleSecondsTotal = 30;

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _selectedCategory = MenuService.categories[0];
  final List<CartItem> _cart = [];
  Timer? _idleTimer;
  int _idleSecondsLeft = IdleSecondsTotal;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

// ---- idle timer --------

  void _touch() {
    _idleSecondsLeft = IdleSecondsTotal;
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
      _idleSecondsLeft = IdleSecondsTotal;
    }
  }

  void _resetOnTimeout() {
    setState(() {
      _cart.clear();
      _selectedCategory = MenuService.categories[0];
      _idleSecondsLeft = IdleSecondsTotal;
    });
  }

  void _selectCategory(String category) {
    setState(() => _selectedCategory = category);
    _touch();
  }

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

  Future<void> _checkout() async {
    _idleTimer?.cancel();
    _idleTimer = null;

    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PaymentPage(items: List.of(_cart))),
    );

    if (!mounted) return;

    if (paid == true) {
      setState(() => _cart.clear());
    } else {
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

  Widget _buildBody() {
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

  Widget _buildProductGrid(List<Product> products) {
    return ProductGrid(
      products: products,
      inCartQty: _inCartQty,
      onToggle: _toggleProduct,
    );
  }

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

            return CategoryTab(
              category: category,
              selected: selected,
              onTap: () => _selectCategory(category),
            );
          },
        ),
      ),
    );
  }
}
