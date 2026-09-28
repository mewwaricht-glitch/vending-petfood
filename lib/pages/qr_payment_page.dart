import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_colors.dart';
import '../services/payment_service.dart';

/// แสดง QR พร้อมเพย์จริงที่สแกนได้สำหรับยอด [amount] บาท
/// แอปธนาคารของฝั่งลูกค้าจะเติมชื่อผู้รับเงินและยอดเงินให้อัตโนมัติ
///
/// หน้าจอนี้เพียงลำพังไม่สามารถรู้แน่ชัดได้ว่ามีการโอนเงินเข้ามาจริง —
/// ต้องมีระบบหลังบ้านที่คอยตรวจสอบความเคลื่อนไหวบัญชี/พร้อมเพย์ เมื่อยัง
/// ไม่มีระบบนั้น ลูกค้า (หรือผู้ดูแลตู้ตอนทดสอบ) จะเป็นคนกดยืนยันเองว่า
/// โอนเงินเสร็จแล้ว เหมือนตู้ไร้คนดูแลขนาดเล็กหลายที่ที่ใช้วิธีให้เจ้าหน้าที่
/// ตรวจสอบ ถ้าจะเชื่อมกับระบบจริง ให้แก้ไขที่ [_confirmPaymentReceived]
/// ให้เรียกไปเช็กสถานะกับ payment gateway จริงแทน
class QrPaymentPage extends StatefulWidget {
  final int amount;

  const QrPaymentPage({super.key, required this.amount});

  @override
  State<QrPaymentPage> createState() => _QrPaymentPageState();
}

class _QrPaymentPageState extends State<QrPaymentPage> {
  static const int _timeoutSeconds = 120;
  int _secondsLeft = _timeoutSeconds;
  Timer? _timer;
  bool _checking = false;
  String? _error;
  late final String _payload;

  @override
  void initState() {
    super.initState();
    try {
      _payload = PaymentService.generatePromptPayPayload(
        promptPayId: PaymentService.merchantPromptPayId,
        amount: widget.amount,
      );
    } catch (e) {
      _payload = '';
      _error = 'ไม่สามารถสร้าง QR ได้: $e';
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsLeft -= 1);
      if (_secondsLeft <= 0) {
        timer.cancel();
        if (mounted) Navigator.of(context).pop(false); // หมดเวลา
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// ใช้แทนการตรวจสอบสถานะการชำระเงินจริง ให้เปลี่ยนไปเรียก backend จริง
  /// ที่เชื่อมกับการแจ้งเตือนพร้อมเพย์ของธนาคารเมื่อมีระบบพร้อมใช้งาน
  Future<void> _confirmPaymentReceived() async {
    setState(() => _checking = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.dark, size: 26),
                    onPressed: _checking ? null : () => Navigator.of(context).pop(false),
                  ),
                  const Text(
                    'สแกนจ่ายพร้อมเพย์',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.dark),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      '${widget.amount} บาท',
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.tulip),
                    ),
                    const SizedBox(height: 4),
                    const Text('เปิดแอปธนาคารแล้วสแกน QR นี้', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: QrImageView(
                        data: _payload,
                        version: QrVersions.auto,
                        size: 220,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'หมดเวลาใน $_secondsLeft วินาที',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                    const Spacer(),
                    if (_checking)
                      const Column(
                        children: [
                          CircularProgressIndicator(color: AppColors.matcha),
                          SizedBox(height: 12),
                          Text('กำลังตรวจสอบการชำระเงิน...'),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _confirmPaymentReceived,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.apples,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          ),
                          child: const Text(
                            'ชำระเงินแล้ว / ตรวจสอบสถานะ',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
