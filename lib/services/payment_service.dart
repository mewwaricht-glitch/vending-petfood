class PaymentService {
  PaymentService._();

  static const String merchantPromptPayId = '0647481396';

  static String generatePromptPayPayload({
    required String promptPayId,
    required num amount,
    String merchantName = 'PET FOOD',
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

  static String _tlv(String id, String value) {
    final len = value.length.toString().padLeft(2, '0');
    return '$id$len$value';
  }

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
