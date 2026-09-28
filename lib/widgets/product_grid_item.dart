import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';

/// การ์ดแสดงสินค้า 1 ชิ้นในกริดของหน้าเมนู (MenuPage)
///
/// แตะที่การ์ดเพื่อเพิ่มสินค้าลงตะกร้า ถ้าสินค้าหมด ([remaining] <= 0)
/// การ์ดจะถูกทำให้จางลงและแตะไม่ได้
class ProductGridItem extends StatelessWidget {
  final Product product;

  /// true = สินค้านี้ถูกเลือกอยู่ในตะกร้าแล้วอย่างน้อย 1 ชิ้น
  final bool selected;

  /// จำนวนที่ยังหยิบเพิ่มได้ (สต๊อกคงเหลือ หักด้วยจำนวนที่อยู่ในตะกร้าแล้ว)
  final int remaining;
  final VoidCallback onTap;

  const ProductGridItem({
    super.key,
    required this.product,
    required this.selected,
    required this.remaining,
    required this.onTap,
  });

  bool get _isOutOfStock => remaining <= 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isOutOfStock ? null : onTap,
      child: Opacity(
        opacity: _isOutOfStock ? 0.4 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(aspectRatio: 1, child: _buildImageCard()),
            const SizedBox(height: 8),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, height: 1.2),
            ),
            const SizedBox(height: 2),
            Text(
              'ขนาด ${product.size}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_formatPrice(product.price)} บาท',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.tomato),
                  ),
                ),
                _buildActionButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ปุ่มวงกลมมุมขวาล่างของการ์ด: เครื่องหมาย "+" ปกติ หรือ "x" ถ้าของหมด
  Widget _buildActionButton() {
    if (_isOutOfStock) {
      return Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: AppColors.textGrey, shape: BoxShape.circle),
        child: const Icon(Icons.close, size: 14, color: Colors.white),
      );
    }
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: AppColors.apples, shape: BoxShape.circle),
      child: const Icon(Icons.add, size: 16, color: Colors.white),
    );
  }

  /// กรอบรูปภาพสินค้า พร้อมกรอบไฮไลท์เมื่อถูกเลือก, เครื่องหมายถูกมุมขวาบน,
  /// และป้าย "หมด" ทับกึ่งกลางถ้าสินค้าหมดสต๊อก
  Widget _buildImageCard() {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: selected ? AppColors.apples.withOpacity(0.12) : AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: selected ? Border.all(color: AppColors.apples, width: 1.4) : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: _buildImage(),
              ),
            ),
          ),
        ),
        if (selected)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: AppColors.apples, shape: BoxShape.circle),
              child: const Icon(Icons.check, size: 13, color: Colors.white),
            ),
          ),
        if (_isOutOfStock)
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('หมด', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          ),
      ],
    );
  }

  /// แสดงรูปภาพของสินค้า ถ้าไม่มีรูปภาพ/โหลดไม่ได้ ให้แสดงไอคอน fallback แทน
  Widget _buildImage() {
    if (product.imagePath.isEmpty) return _buildFallbackIcon();

    return Image.asset(
      product.imagePath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
    );
  }

  Widget _buildFallbackIcon() {
    return const Center(
      child: Icon(Icons.image_not_supported, size: 36, color: Colors.grey),
    );
  }

  /// จัดรูปแบบตัวเลขราคาให้มีจุลภาคคั่นหลักพัน เช่น 1234 -> "1,234"
  static String _formatPrice(int price) {
    final digits = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i != 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
