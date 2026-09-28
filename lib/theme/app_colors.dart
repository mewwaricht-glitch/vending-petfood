import 'package:flutter/material.dart';

/// สี/สไตล์กลางของแอป ให้ทุกหน้าจอใช้โทนสีเดียวกันตามดีไซน์
/// "PET BOX" (การ์ดมุมโค้ง, แท็บทรงเม็ดยา, ปุ่มเพิ่มสีเขียว,
/// สีส้ม/แดงสำหรับราคาและปุ่มหลัก)
class AppColors {
  AppColors._(); // ห้ามสร้าง instance ใช้เป็นค่าคงที่ (static) เท่านั้น

  static const Color tomato = Color(0xFFbc1414); // สีหลักของแบรนด์ (ราคา, ปุ่มหลัก)
  static const Color dark = Color(0xFF1F1F1F); // สีตัวอักษร/แท็บที่เลือกอยู่
  static const Color apples = Color(0xFF699543); // สีปุ่ม "+" เพิ่มสินค้า
  static const Color basil = Color(0xFFa2a93e);
  static const Color matcha = Color(0xFFd6d2a5);
  static const Color tulip = Color(0xFFd28752);
  static const Color cardBg = Color(0xFFF4F4F6); // พื้นหลังกรอบรูปสินค้า (สีเทาอ่อน)
  static const Color panelBg = Color(0xFFF7F7F9); // พื้นหลังแผงสรุปรายการ
  static const Color border = Color(0xFFE3E3E6);
  static const Color textGrey = Color(0xFF9A9AA2);
}

/// ทรงพื้นหลังแบบเม็ดยา (pill) มุมโค้งมน ใช้กับแท็บ/ชิป
/// [selected] = true จะเป็นพื้นดำตัวหนังสือขาว, false จะเป็นพื้นขาวขอบเทา
BoxDecoration pillDecoration({required bool selected}) {
  return BoxDecoration(
    color: selected ? AppColors.dark : Colors.white,
    borderRadius: BorderRadius.circular(24),
    border: selected ? null : Border.all(color: AppColors.border, width: 1.2),
  );
}
