import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';

/// แถบตะกร้าสินค้าด้านล่างของหน้าเมนู (MenuPage)
///
/// แสดงรายการสินค้าที่เลือกไว้แบบเลื่อนแนวนอน, เวลานับถอยหลังก่อนรีเซ็ต
/// (idle timeout), ยอดรวม, และปุ่ม "ล้างทั้งหมด" / "ชำระเงิน"
/// วิดเจ็ตนี้ไม่มี state ของตัวเอง (StatelessWidget) — MenuPage เป็นคนคุม
/// ข้อมูลตะกร้าทั้งหมด แล้วส่ง callback เข้ามาให้เรียกตอนผู้ใช้กดปุ่มต่าง ๆ
class CartBar extends StatelessWidget {
  final List<CartItem> items;

  /// จำนวนวินาทีที่เหลือก่อนตู้จะรีเซ็ตกลับเมนูเริ่มต้นเพราะไม่มีการกดหน้าจอ
  final int idleSecondsLeft;
  final VoidCallback onClearAll;
  final VoidCallback onCheckout;

  /// เรียกเมื่อกดปุ่ม +/- เพื่อเพิ่ม/ลดจำนวนสินค้าในตะกร้า (delta = +1 หรือ -1)
  final void Function(CartItem item, int delta) onChangeQty;

  /// เรียกเมื่อกดปุ่ม "X" เพื่อลบสินค้ารายการนั้นออกจากตะกร้าทั้งหมด
  final void Function(CartItem item) onRemove;

  const CartBar({
    super.key,
    required this.items,
    required this.idleSecondsLeft,
    required this.onClearAll,
    required this.onCheckout,
    required this.onChangeQty,
    required this.onRemove,
  });

  int get totalCount => items.fold(0, (sum, i) => sum + i.quantity);
  int get totalPrice => items.fold(0, (sum, i) => sum + i.lineTotal);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // แถวชิปแสดงสินค้าในตะกร้า (เลื่อนแนวนอนได้) — ซ่อนถ้าตะกร้าว่าง
            if (items.isNotEmpty)
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _CartChip(
                      item: item,
                      onIncrement: () => onChangeQty(item, 1),
                      onDecrement: () => onChangeQty(item, -1),
                      onRemove: () => onRemove(item),
                    );
                  },
                ),
              ),
            // ข้อความนับถอยหลังก่อนตู้จะรีเซ็ตอัตโนมัติ
            if (items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'ล้างทั้งหมดในอีก $idleSecondsLeft วินาที',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
            // แถวล่างสุด: ปุ่มล้างตะกร้า, ยอดรวม, ปุ่มชำระเงิน
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: items.isEmpty ? null : onClearAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tomato,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 6),
                        Text('ล้างทั้งหมด', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'ทั้งหมด $totalCount ชิ้น ${_formatPrice(totalPrice)} บาท',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.dark),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: items.isEmpty ? null : onCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tulip,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    ),
                    child: const Text('ชำระเงิน', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// จัดรูปแบบตัวเลขราคาให้มีจุลภาคคั่นหลักพัน เช่น 1234 -> "1,234"
  static String _formatPrice(int price) {
    final s = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

/// การ์ดเล็ก ๆ 1 ใบในแถบตะกร้า แสดงชื่อสินค้า ราคา และปุ่มปรับจำนวน +/-
class _CartChip extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartChip({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.panelBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.cancel, size: 20, color: AppColors.tomato),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${item.product.price} บาท', style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
              Row(
                children: [
                  _stepButton(Icons.remove, onDecrement),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  _stepButton(Icons.add, onIncrement),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade400)),
        child: Icon(icon, size: 13),
      ),
    );
  }
}
