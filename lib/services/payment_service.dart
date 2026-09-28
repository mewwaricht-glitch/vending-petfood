/// บริการ (service) สำหรับสร้างข้อมูล QR Code พร้อมเพย์ (PromptPay)
///
/// รวม logic การเข้ารหัสข้อมูลตามมาตรฐาน EMVCo ไว้ในที่เดียว แยกออกจาก
/// หน้าจอ (pages) เพื่อให้หน้าจอไม่ต้องยุ่งกับรายละเอียดการเข้ารหัส
/// แค่เรียก [PaymentService.generatePromptPayPayload] แล้วเอาผลลัพธ์
/// (ข้อความ payload) ไปสร้างเป็น QR image ต่อได้เลย
class PaymentService {
  PaymentService._(); // ไม่ต้องสร้าง instance ใช้งานแบบ static เท่านั้น

  /// เบอร์พร้อมเพย์เริ่มต้นที่ใช้ทดสอบ (ของจริงควรตั้งค่าใน config/payment_config.dart)
  static const String merchantPromptPayId = '0647481396';

  /// สร้างข้อความ (payload) สำหรับ QR พร้อมเพย์ ตามมาตรฐาน EMVCo
  ///
  /// [promptPayId] ต้องเป็นเบอร์มือถือ 10 หลักที่ขึ้นต้นด้วย 0
  /// [amount] คือยอดเงินที่ต้องชำระ (บาท)
  /// เมื่อสแกนด้วยแอปธนาคารใดก็ได้ จะขึ้นชื่อผู้รับ+ยอดเงินให้อัตโนมัติ
  static String generatePromptPayPayload({
    required String promptPayId,
    required num amount,
    String merchantName = 'PET BOX',
    String merchantCity = 'BANGKOK',
  }) {
    final digits = promptPayId.replaceAll(RegExp(r'[^0-9]'), '');

    String targetTag;
    String targetValue;
    if (digits.length == 10 && digits.startsWith('0')) {
      targetTag = '01';
      targetValue = '66${digits.substring(1)}'.padLeft(13, '0');
    } else {
      throw ArgumentError(
        'PromptPay ID must be a 10-digit mobile number',
      );
    }

    final merchantAccountInfo =
        _tlv('00', 'A000000677010111') + _tlv(targetTag, targetValue);

    final buffer = StringBuffer()
      ..write(_tlv('00', '01')) // Payload Format Indicator
      ..write(_tlv('01', '12')) // Point of Initiation: 12 = dynamic (fixed amount, one-time)
      ..write(_tlv('29', merchantAccountInfo)) // Merchant Account Info: PromptPay
      ..write(_tlv('53', '764')) // Transaction Currency: 764 = THB
      ..write(_tlv('54', amount.toStringAsFixed(2))) // Transaction Amount
      ..write(_tlv('58', 'TH')) // Country Code
      ..write(_tlv('59', merchantName.length > 25 ? merchantName.substring(0, 25) : merchantName))
      ..write(_tlv('60', merchantCity.length > 15 ? merchantCity.substring(0, 15) : merchantCity));

    final withCrcHeader = '${buffer.toString()}6304';
    return withCrcHeader + _crc16Ccitt(withCrcHeader);
  }

  /// ห่อค่า [id]/[value] ให้อยู่ในรูปแบบ TLV (Tag-Length-Value) ตามสเปก EMVCo
  static String _tlv(String id, String value) {
    final len = value.length.toString().padLeft(2, '0');
    return '$id$len$value';
  }

  /// คำนวณค่า checksum CRC16-CCITT ที่ต้องแนบท้าย payload ของ QR พร้อมเพย์
  static String _crc16Ccitt(String data) {
    const poly = 0x1021;
    int crc = 0xFFFF;
    for (final unit in data.codeUnits) {
      crc ^= (unit << 8);
      for (int i = 0; i < 8; i++) {
        crc = (crc & 0x8000) != 0 ? ((crc << 1) ^ poly) & 0xFFFF : (crc << 1) & 0xFFFF;
      }
    }
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }
}
