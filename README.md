# Kiosk Vending Machine (Flutter)

โปรเจกต์ Flutter จำลอง UI ตู้ขายเครื่องดื่มแบบ kiosk (สไตล์ Sul.bing) ครบทั้งกระบวนการ:

1. **หน้า Intro** – แตะหน้าจอเพื่อเริ่มสั่งซื้อ
2. **หน้าเมนูหลัก** – แท็บหมวดหมู่ (설빙 / 커피·라떼 / 차 / 스무디·에이드 / 디저트),
   กริดสินค้า 4 คอลัมน์พร้อม pagination, ตะกร้าสินค้าด้านล่างพร้อมปุ่ม +/-,
   ลบทีละชิ้น/ลบทั้งหมด, ตัวนับเวลาถอยหลังกลับหน้า Intro อัตโนมัติเมื่อไม่มีการแตะหน้าจอ
3. **หน้าเลือกวิธีชำระเงิน** – บัตรเครดิต / เงินสด / QR พร้อมสถานะ "กำลังประมวลผล"
4. **หน้าใบเสร็จ/สำเร็จ** – แสดงหมายเลขออเดอร์ รายการสินค้า ยอดรวม
   และนับถอยหลังกลับหน้า Intro อัตโนมัติ

## โครงสร้างไฟล์

จัดเป็นแบบ model / service / pages เพื่อให้แยกหน้าที่ของแต่ละไฟล์ชัดเจน:

```
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
```

## วิธีรัน

```bash
flutter pub get
flutter run
```

รองรับทั้ง mobile, web (`flutter run -d chrome`) และ desktop — ไม่มี dependency
ภายนอกนอกจาก Flutter SDK เอง จึงรันได้ทันที

## จุดที่ปรับแต่งได้ง่าย

- **เพิ่ม/แก้เมนู**: แก้ใน `lib/services/menu_service.dart` (ชื่อ, ราคา, หมวดหมู่, รูปภาพ)
- **เวลานับถอยหลังกลับหน้าเมนู**: `kIdleSecondsTotal` ใน `pages/menu_page.dart`
  และ `_autoReturnSeconds` ใน `pages/receipt_page.dart`
- **สีธีมหลัก**: แก้ค่าคงที่ในคลาส `AppColors` ที่ `lib/theme/app_colors.dart`
- **เบอร์พร้อมเพย์/ธนบัตร-เหรียญที่รับ**: `lib/config/payment_config.dart`
- **รูปสินค้า**: อยู่ใน `assets/cat`, `assets/dog`, `assets/hamster` แล้วอ้างอิง path ใน
  `menu_service.dart`, ถ้าไฟล์รูปหาไม่เจอ `ProductGridItem` จะแสดงไอคอน fallback ให้อัตโนมัติ

## แนวคิดการทำงาน (state management)

ใช้ `StatefulWidget` + `setState` ธรรมดา ไม่มี dependency เพิ่มเติม (ไม่ใช้ Provider/Riverpod)
เพื่อให้อ่านและแก้โค้ดง่ายที่สุด ตะกร้าสินค้า (`_cart`) เป็น state หลักอยู่ใน `MenuPage`
ส่งต่อไปหน้าชำระเงิน/ใบเสร็จผ่าน constructor + `Navigator.push` แบบ async/await
