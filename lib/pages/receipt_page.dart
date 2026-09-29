import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../models/payment_method.dart';
import '../widgets/receipt_item.dart';

class ReceiptPage extends StatefulWidget {
  final List<CartItem> items;
  final int orderNumber;
  final PaymentMethod method;
  final int changeGiven;

  const ReceiptPage({
    super.key,
    required this.items,
    required this.orderNumber,
    required this.method,
    this.changeGiven = 0,
  });

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  static const int _autoReturnSeconds = 6;
  int _secondsLeft = _autoReturnSeconds;
  Timer? _timer;

  int get total => widget.items.fold(0, (sum, i) => sum + i.lineTotal);

  String get _methodLabel {
    switch (widget.method) {
      case PaymentMethod.cash:
        return 'เงินสด';
      case PaymentMethod.mobilePay:
        return 'พร้อมเพย์ (QR)';
    }
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsLeft -= 1);
      if (_secondsLeft <= 0) {
        timer.cancel();
        _finish();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _finish() {
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        Container(
                          width: 84,
                          height: 84,
                          decoration: const BoxDecoration(color: AppColors.apples, shape: BoxShape.circle),
                          child: const Icon(Icons.check, color: Colors.white, size: 48),
                        ),
                        const SizedBox(height: 20),
                        const Text('ชำระเงินสำเร็จ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text('วิธีชำระเงิน: $_methodLabel', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.panelBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'หมายเลขคำสั่งซื้อ ${widget.orderNumber}',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.tulip),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ...widget.items.map((i) => ReceiptItem(item: i)),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text('ยอดชำระทั้งหมด',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                            ),
                            Text('$total บาท', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
                          ],
                        ),
                        if (widget.method == PaymentMethod.cash && widget.changeGiven > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text('เงินทอน',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 15, color: Colors.grey)),
                              ),
                              Text('${widget.changeGiven} บาท', style: const TextStyle(fontSize: 15, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _finish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.apples,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'ตกลง (กลับหน้าแรกใน $_secondsLeft วินาที)',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
