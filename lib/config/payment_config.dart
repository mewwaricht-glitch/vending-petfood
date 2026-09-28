class PaymentConfig {
  /// เบอร์พร้อมเพย์/เลขผู้รับเงินของเจ้าของตู้ (ค่าเริ่มต้นเป็นเลขหลอก ต้องแก้ก่อนใช้งานจริง)
  static const String merchantPromptPayId = '0000000000';

  /// ชื่อร้านที่จะแสดงในสลิป/แอปธนาคารของลูกค้า
  static const String merchantDisplayName = 'Pet Food Vending Machine';

  /// ธนบัตรที่ตู้รับ เรียงจากใบใหญ่ไปเล็ก
  static const List<int> acceptedMoney = [100, 50, 20, 10, 5, 2];

  /// เหรียญที่ตู้รับ เรียงจากเหรียญใหญ่ไปเล็ก
  static const List<int> acceptedCoins = [10, 5, 2, 1];

  /// หน่วยเงินที่ตู้ใช้ทอน (ตู้จริงมักสำรองไว้เป็นเหรียญ+แบงค์ย่อยเท่านั้น)
  static const List<int> changeDenominations = [100, 50, 20, 10, 5, 2, 1];
}
