import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = []; //สร้าง list สำหรับเก็บสินค้าในตะกร้า

  List<CartItem> get items =>
      _items; //getter สำหรับให้หน้าอื่นอ่านรายการสินค้าในตะกร้าได้

  int get itemCount => _items.length; //ใช้ดูจำนวนรายการสินค้าในตะกร้า

  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  } //ใช้คำนวณราคารวมทั้งหมดในตะกร้า

  void addToCart(Product product, {int quantity = 1}) {
    //ฟังก์ชันนี้ใช้เพิ่มสินค้าเข้าไปในตะกร้า
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    ); //ค้นหาว่าสินค้านี้มีอยู่ในตะกร้าแล้วหรือยัง

    if (existingIndex >= 0) {
      //ถ้า existingIndex >= 0 แปลว่าสินค้านี้มีอยู่ในตะกร้าแล้ว
      final newQuantity =
          _items[existingIndex].quantity + quantity; //คำนวณจำนวนใหม่
      if (newQuantity <= product.quantity) {
        _items[existingIndex].quantity = newQuantity;
      } //ตรวจว่าจำนวนใหม่ไม่เกินจำนวนสินค้าที่มีอยู่จริง
    } else {
      if (quantity <= product.quantity) {
        _items.add(
          CartItem(product: product, quantity: quantity),
        ); //ตรวจว่าจำนวนที่ต้องการเพิ่มไม่เกิน stock
      }
    }
    notifyListeners(); //แจ้ง UI ว่าตะกร้ามีการเปลี่ยนแปลงแล้ว
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= _items[index].product.quantity) {
        _items[index].quantity = quantity;
        notifyListeners();
      }
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  int getQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      return _items[index].quantity;
    }
    return 0;
  }
}
