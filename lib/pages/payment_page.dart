import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import 'cash_payment_page.dart';
import 'qr_payment_page.dart';
import 'receipt_page.dart';

/// ช่องทางการชำระเงินที่ตู้รองรับ
enum PaymentMethod { card, cash, mobilePay }

/// หน้าสรุปคำสั่งซื้อและเลือกช่องทางชำระเงิน
///
/// รับรายการสินค้าที่ลูกค้าเลือกไว้ ([items]) มาแสดงสรุปยอด แล้วให้เลือก
/// จ่ายด้วยเงินสดหรือ QR พร้อมเพย์ จากนั้นพาไปหน้าที่เกี่ยวข้อง
/// (CashPaymentPage / QrPaymentPage) และสุดท้ายไปหน้าใบเสร็จ (ReceiptPage)
class PaymentPage extends StatefulWidget {
  final List<CartItem> items;

  const PaymentPage({super.key, required this.items});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _processing = false;

  int get total => widget.items.fold(0, (sum, i) => sum + i.lineTotal);

  /// จัดการขั้นตอนการจ่ายเงินตามช่องทางที่เลือก แล้วต่อไปหน้าใบเสร็จเมื่อสำเร็จ
  Future<void> _pay(PaymentMethod method) async {
    switch (method) {
      case PaymentMethod.cash:
        // เครื่องรับเงินสดจริง: ลูกค้าหยอดแบงค์/เหรียญ เครื่องรอจนครบยอด
        // แล้วทอนเงินคืนถ้ามีเงินทอน
        final result = await Navigator.of(context).push<CashPaymentResult>(
          MaterialPageRoute(builder: (_) => CashPaymentPage(amountDue: total)),
        );
        if (!mounted || result == null) return; // ยกเลิก -> คืนเงินทั้งหมด อยู่หน้านี้ต่อ
        await _finishOrder(method, changeGiven: result.change);
        return;

      case PaymentMethod.mobilePay:
        // QR พร้อมเพย์จริงที่สแกนได้ ตรงกับยอดคำสั่งซื้อพอดี
        final confirmed = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => QrPaymentPage(amount: total)),
        );
        if (!mounted || confirmed != true) return; // ยกเลิกหรือหมดเวลา
        await _finishOrder(method);
        return;

      case PaymentMethod.card:
        setState(() => _processing = true);
        // จำลองการติดต่อเครื่องรูดบัตร/payment gateway
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        await _finishOrder(method);
        return;
    }
  }

  /// สร้างเลขที่คำสั่งซื้อและพาไปหน้าใบเสร็จ จากนั้นรายงานผลกลับไปยัง MenuPage
  Future<void> _finishOrder(PaymentMethod method, {int changeGiven = 0}) async {
    setState(() => _processing = true);
    final orderNumber = 100 + DateTime.now().second;

    final success = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ReceiptPage(
          items: widget.items,
          orderNumber: orderNumber,
          method: method,
          changeGiven: changeGiven,
        ),
      ),
    );

    if (!mounted) return;
    // ไม่ว่าหน้าใบเสร็จจะคืนค่าอะไรมา ถือว่าคำสั่งซื้อเสร็จสิ้นแล้ว:
    // แจ้งผลสำเร็จกลับไปยังหน้าที่เรียกมา (MenuPage)
    Navigator.of(context).pop(success ?? true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _processing
          ? _buildProcessing()
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      children: [
                        _buildOrderSummary(),
                        const SizedBox(height: 24),
                        const Text(
                          'เลือกช่องทางการชำระเงิน',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.dark),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _PaymentOptionCard(
                                label: 'เงินสด',
                                onTap: () => _pay(PaymentMethod.cash),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _PaymentOptionCard(
                                label: 'QR Code\nพร้อมเพย์',
                                onTap: () => _pay(PaymentMethod.mobilePay),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.dark, size: 26),
            onPressed: _processing ? null : () => Navigator.of(context).pop(false),
          ),
          const Text(
            'ชำระเงิน',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.dark),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('รายการคำสั่งซื้อ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.dark)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.panelBg,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              for (int i = 0; i < widget.items.length; i++) ...[
                if (i != 0) const Divider(height: 1, color: AppColors.border),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.items[i].product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text('x${widget.items[i].quantity}', style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
                          ],
                        ),
                      ),
                      Text('${widget.items[i].lineTotal} บาท', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.tulip,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ยอดชำระทั้งหมด', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              Text('$total บาท', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProcessing() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.tulip),
          SizedBox(height: 24),
          Text('กำลังดำเนินการชำระเงิน...', style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text('กรุณาอย่าถอดบัตร', style: TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }
}

/// การ์ดปุ่มเลือกช่องทางชำระเงิน 1 ใบ (เช่น "เงินสด", "QR พร้อมเพย์")
/// มี animation ตอนกดค้าง (เปลี่ยนสีพื้นหลัง/ขอบ) เพื่อ feedback ให้ผู้ใช้
class _PaymentOptionCard extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _PaymentOptionCard({required this.label, required this.onTap});

  @override
  State<_PaymentOptionCard> createState() => _PaymentOptionCardState();
}

class _PaymentOptionCardState extends State<_PaymentOptionCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 110,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: _pressed ? AppColors.basil : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _pressed ? AppColors.matcha : AppColors.border,
            width: 1.4,
          ),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: AppColors.matcha.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 120),
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _pressed ? Colors.white : AppColors.dark,
          ),
          textAlign: TextAlign.center,
          child: Text(widget.label),
        ),
      ),
    );
  }
}
