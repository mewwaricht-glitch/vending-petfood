import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// ผลลัพธ์ของการจ่ายด้วยเงินสด: จำนวนเงินที่หยอดเข้ามา และเงินทอนที่ต้องจ่ายคืน
class CashPaymentResult {
  final int inserted;
  final int change;
  const CashPaymentResult({required this.inserted, required this.change});
}

/// หน้าจอจำลองเครื่องรับเงินสด (หยอดแบงค์/เหรียญ) ของตู้
///
/// ลูกค้ากดปุ่มแต่ละหน่วยเงินเพื่อ "หยอด" ทีละใบ/เหรียญ จนกว่าจะครบยอด
/// ที่ต้องชำระ ([amountDue]) จากนั้นกดยืนยันเพื่อให้เครื่องคำนวณและ
/// "ทอนเงิน" คืนให้ (ถ้ามี)
class CashPaymentPage extends StatefulWidget {
  final int amountDue;

  const CashPaymentPage({super.key, required this.amountDue});

  @override
  State<CashPaymentPage> createState() => _CashPaymentPageState();
}

class _CashPaymentPageState extends State<CashPaymentPage> {
  // ธนบัตรและเหรียญไทย เรียงจากใบใหญ่ไปเล็ก
  static const List<_Denomination> _banknotes = [
    _Denomination(100, isNote: true),
    _Denomination(50, isNote: true),
    _Denomination(20, isNote: true),
  ];
  static const List<_Denomination> _coins = [
    _Denomination(10, isNote: false),
    _Denomination(5, isNote: false),
    _Denomination(2, isNote: false),
    _Denomination(1, isNote: false),
  ];

  final Map<int, int> _counts = {
    for (final d in [..._banknotes, ..._coins]) d.value: 0,
  };

  bool _confirming = false;
  bool _done = false;
  late int _change;

  int get _inserted => _counts.entries.fold(0, (sum, e) => sum + e.key * e.value);
  int get _remaining => (widget.amountDue - _inserted).clamp(0, widget.amountDue);
  bool get _canConfirm => _inserted >= widget.amountDue;

  void _insert(int value) {
    // ไม่รับเงินเพิ่มเติมถ้าถึงยอดราคาแล้ว
    if (_inserted >= widget.amountDue) return;
    setState(() => _counts[value] = (_counts[value] ?? 0) + 1);
  }

  void _removeOne(int value) {
    final current = _counts[value] ?? 0;
    if (current == 0) return;
    setState(() => _counts[value] = current - 1);
  }

  void _resetAll() {
    setState(() {
      for (final key in _counts.keys) {
        _counts[key] = 0;
      }
    });
  }

  /// แบ่งจำนวนเงินทอนออกเป็นหน่วยธนบัตร/เหรียญมาตรฐาน แบบ greedy
  /// (หน่วยใหญ่สุดก่อน) เสมือนตู้ทอนเงินจริง
  List<MapEntry<int, int>> _changeBreakdown(int amount) {
    const allDenoms = [100, 50, 20, 10, 5, 2, 1];
    final result = <MapEntry<int, int>>[];
    var remaining = amount;
    for (final d in allDenoms) {
      final count = remaining ~/ d;
      if (count > 0) {
        result.add(MapEntry(d, count));
        remaining -= d * count;
      }
    }
    return result;
  }

  Future<void> _confirm() async {
    setState(() {
      _confirming = true;
      _change = _inserted - widget.amountDue;
    });
    // จำลองเวลาที่เครื่องนับเหรียญ/ธนบัตรและทอนเงิน
    await Future.delayed(Duration(milliseconds: _change > 0 ? 900 : 400));
    if (!mounted) return;
    setState(() {
      _confirming = false;
      _done = true;
    });
  }

  void _finishAndReturn() {
    Navigator.of(context).pop(
      CashPaymentResult(inserted: _inserted, change: _change),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(
              child: _confirming
                  ? _buildDispensingChange()
                  : _done
                      ? _buildDone()
                      : _buildInsertUi(),
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
            onPressed: (_confirming || _done)
                ? null
                : () => Navigator.of(context).pop(null), // ยกเลิก: คืนเงินที่หยอดไปทั้งหมด
          ),
          const Text(
            'หยอดเหรียญ/ธนบัตร',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.dark),
          ),
        ],
      ),
    );
  }

  /// หน้าจอหลักระหว่างหยอดเงิน: สรุปยอด + ปุ่มหยอดแต่ละหน่วยเงิน
  Widget _buildInsertUi() {
    return Column(
      children: [
        _buildAmountSummary(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('เงินสด', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  if (_canConfirm)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.basil.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [..._banknotes, ..._coins]
                .map((d) => _DenomButton(
                  denomination: d,
                  count: _counts[d.value] ?? 0,
                  onInsert: _canConfirm ? null : () => _insert(d.value),
                  onRemoveOne: () => _removeOne(d.value),
                  ))
                  .toList(),
                  ),
            ],
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildAmountSummary() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _summaryRow('ยอดที่ต้องชำระ', '${widget.amountDue} บาท'),
          const SizedBox(height: 6),
          _summaryRow('หยอดเงินแล้ว', '$_inserted บาท'),
          const Divider(height: 20),
          _summaryRow(
            _canConfirm ? 'เงินทอน' : 'ขาดอีก',
            _canConfirm ? '${_inserted - widget.amountDue} บาท' : '$_remaining บาท',
            emphasize: true,
            color: _canConfirm ? AppColors.basil : AppColors.apples,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool emphasize = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: emphasize ? 16 : 14, fontWeight: emphasize ? FontWeight.bold : FontWeight.normal)),
        Text(
          value,
          style: TextStyle(
            fontSize: emphasize ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _resetAll,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('ล้างทั้งหมด', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canConfirm ? _confirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.apples,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _canConfirm ? 'ยืนยันการชำระเงิน' : 'หยอดเงินให้ครบ',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDispensingChange() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.matcha),
          SizedBox(height: 24),
          Text('กำลังนับเงินและทอนเงิน...', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDone() {
    final breakdown = _changeBreakdown(_change);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(color: AppColors.apples, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 48),
                  ),
                  const SizedBox(height: 20),
                  const Text('รับเงินครบแล้ว', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _summaryRow('รับเงินทั้งหมด', '$_inserted บาท'),
                        const SizedBox(height: 6),
                        _summaryRow('ยอดชำระ', '${widget.amountDue} บาท'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_change > 0) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('กรุณารับเงินทอนช่องรับเงินทอน', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.tulip.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.tomato, width: 1.2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('เงินทอนทั้งหมด', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('$_change บาท', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.tomato)),
                            ],
                          ),
                          const Divider(height: 20),
                          ...breakdown.map(
                            (e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${e.key >= 20 ? 'แบงก์' : 'เหรียญ'} ${e.key} บาท'),
                                  Text('x ${e.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    const Text('ไม่มีเงินทอน', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _finishAndReturn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.apples,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: const Text('ดำเนินการต่อ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

/// หน่วยเงิน 1 ชนิด (เช่น แบงค์ 100 หรือเหรียญ 5) ที่ปุ่มหยอดเงินอ้างอิงถึง
class _Denomination {
  final int value;
  final bool isNote;
  const _Denomination(this.value, {required this.isNote});
}

/// ปุ่มหยอดเงิน 1 หน่วย พร้อมตัวเลขนับจำนวนที่หยอดไปแล้ว และปุ่ม +/-
/// เพื่อแก้ไขจำนวนก่อนยืนยัน
class _DenomButton extends StatelessWidget {
  final _Denomination denomination;
  final int count;
  final VoidCallback? onInsert;
  final VoidCallback onRemoveOne;

  const _DenomButton({
    required this.denomination,
    required this.count,
    required this.onInsert,
    required this.onRemoveOne,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onInsert != null;

    return SizedBox(
      width: 96,
      child: Column(
        children: [
          GestureDetector(
            onTap: isEnabled ? onInsert : null,
            child: Container(
              width: 96,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isEnabled ? Colors.white : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isEnabled ? Colors.grey.shade400 : Colors.grey.shade300,
                  width: 1.4,
                ),
              ),
              child: Text(
                '${denomination.value}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isEnabled ? AppColors.dark : Colors.grey.shade500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: count > 0 ? onRemoveOne : null,
                child: Icon(
                  Icons.remove_circle_outline,
                  size: 20,
                  color: count > 0 ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              SizedBox(
                width: 28,
                child: Text('$count', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              GestureDetector(
                onTap: isEnabled ? onInsert : null,
                child: Icon(
                  Icons.add_circle_outline,
                  size: 20,
                  color: isEnabled ? AppColors.matcha : Colors.grey.shade300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
