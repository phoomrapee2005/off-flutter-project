import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _apiService.getProducts();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load products';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProduct(Product product) async {//รับค่า Product product คือข้อมูลสินค้าที่ต้องการเพิ่ม คืนค่าเป็น Future<bool> เพราะต้องรอการบันทึกข้อมูล และผลลัพธ์จะเป็น:
    _isLoading = true;//ตั้งค่าว่าระบบกำลังโหลด หรือกำลังเพิ่มสินค้าอยู่
    _error = null;//ล้างข้อความ error เก่าก่อนเริ่มเพิ่มสินค้าใหม่
    notifyListeners();//แจ้ง UI ว่าข้อมูลเปลี่ยนแล้ว

    try {//เริ่มส่วนที่อาจเกิด error ได้ เช่น การบันทึกสินค้าลง database หรือ backend
      final success = await _apiService.createProduct(product);//ส่งข้อมูลสินค้าไปให้ _apiService.createProduct(product) เพื่อเพิ่มสินค้าใหม่
      if (success) {//ตรวจสอบว่าเพิ่มสินค้าสำเร็จหรือไม่
        await loadProducts();//ถ้าเพิ่มสินค้าสำเร็จ จะโหลดรายการสินค้าทั้งหมดใหม่
        return true;//ส่งค่ากลับไปว่าเพิ่มสินค้าสำเร็จ
      }
      _error = 'Failed to add product';//ถ้า _apiService.createProduct(product) ส่งผลว่าไม่สำเร็จ
      return false;
    } on ApiException catch (e) {//ถ้าเกิด error แบบ ApiException จะเข้ามาส่วนนี้
      _error = e.message;//นำข้อความ error จาก ApiException มาเก็บไว้ใน _error
      return false;
    } catch (e) {//ถ้าเกิด error อื่น ๆ ที่ไม่ใช่ ApiException จะเข้ามาส่วนนี้
      _error = 'An unexpected error occurred';//เก็บข้อความ error ทั่วไปว่าเกิดข้อผิดพลาดที่ไม่คาดคิด
      return false;
    } finally {//ส่วนนี้จะทำงานเสมอ ไม่ว่าจะเพิ่มสินค้าสำเร็จหรือเกิด error
      _isLoading = false;//ปิดสถานะ loading เพราะทำงานเสร็จแล้ว
      notifyListeners();//แจ้ง UI อีกครั้งว่าการโหลดจบแล้ว หรือมี error เกิดขึ้น
    }
  }

  Future<bool> updateProduct(Product product) async {
    _isLoading = true; //ตั้งค่าว่ากำลังโหลดหรือกำลังอัปเดตข้อมูลอยู่
    _error = null; //ล้าง error เก่าก่อนเริ่มทำงานใหม่
    notifyListeners(); //แจ้งหน้าจอที่ฟัง Provider อยู่ว่าข้อมูลเปลี่ยนแล้ว

    try {
      //เริ่มส่วนที่อาจเกิด error ได้ เช่น การเรียก API หรือ database
      final success = await _apiService.updateProduct(
        product,
      ); //ส่งข้อมูลสินค้าไปให้ _apiService.updateProduct(product) เพื่ออัปเดตสินค้า
      if (success) {
        //ถ้าอัปเดตสินค้าสำเร็จ
        await loadProducts(); //โหลดรายการสินค้าทั้งหมดใหม่อีกครั้ง
        return true; //ส่งค่ากลับว่าแก้ไขสำเร็จ
      }
      _error =
          'Failed to update product'; //ถ้า _apiService.updateProduct(product) ไม่สำเร็จ
      return false; //จะเก็บข้อความ error ว่าแก้ไขสินค้าไม่สำเร็จ แล้วส่ง false กลับไป
    } on ApiException catch (e) {
      //ถ้าเกิด error แบบ ApiException จะเข้ามาส่วนนี้
      _error = e.message;
      return false; //เก็บข้อความ error จาก API แล้วส่งกลับว่าไม่สำเร็จ
    } catch (e) {
      //ถ้าเกิด error อื่น ๆ ที่ไม่ใช่ ApiException จะเข้ามาส่วนนี้
      _error = 'An unexpected error occurred';
      return false; //เก็บข้อความ error ทั่วไปว่าเกิดข้อผิดพลาดที่ไม่คาดคิด แล้วส่งกลับว่าไม่สำเร็จ
    } finally {
      //ส่วนนี้จะทำงานเสมอ ไม่ว่าจะสำเร็จหรือ error
      _isLoading = false; //ปิดสถานะ loading เพราะทำงานเสร็จแล้ว
      notifyListeners(); //แจ้ง UI อีกครั้งว่า loading จบแล้ว หรือมี error เกิดขึ้น
    }
  }

  Future<bool> deleteProduct(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.deleteProduct(id);
      if (success) {
        await loadProducts();
        return true;
      }
      _error = 'Failed to delete product';
      return false;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    return _products
        .where(
          (p) =>
              p.name.toLowerCase().contains(query.toLowerCase()) ||
              p.modelName.toLowerCase().contains(query.toLowerCase()) ||
              p.category.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  List<Product> getNewProducts() {
    return _products.where((p) => p.condition == 'new').toList();
  }

  List<Product> getUsedProducts() {
    return _products.where((p) => p.condition == 'used').toList();
  }
}
