## โครงสร้างไฟล์

lib/
  main.dart                        // entry point ของแอป
  models/
    product.dart                   // Product, CartItem — คลาสข้อมูลล้วน ๆ
  services/
    menu_service.dart              // ข้อมูลสินค้า+หมวดหมู่ทั้งหมด (แก้ไข/เพิ่มเมนูที่นี่)
    payment_service.dart           // สร้าง payload QR พร้อมเพย์ (EMVCo)
  pages/
    intro_page.dart                // หน้าต้อนรับ (ยังไม่ถูกเรียกใช้ในลำดับปัจจุบัน)
    menu_page.dart                 // หน้าหลัก: หมวดหมู่ + กริด + ตะกร้า + idle timer
    payment_page.dart              // เลือกช่องทางชำระเงิน
    cash_payment_page.dart         // หยอดเหรียญ/ธนบัตร + ทอนเงิน
    qr_payment_page.dart           // แสดง QR พร้อมเพย์ให้สแกน
    receipt_page.dart              // ใบเสร็จ + auto กลับหน้าเมนู
  widgets/
    product_grid_item.dart         // การ์ดสินค้าในกริด
    cart_bar.dart                  // แถบตะกร้าด้านล่าง
  theme/
    app_colors.dart                // สี/สไตล์กลางของแอป
  config/
    payment_config.dart            // ค่าตั้งค่าพร้อมเพย์/ธนบัตร-เหรียญที่รับ
