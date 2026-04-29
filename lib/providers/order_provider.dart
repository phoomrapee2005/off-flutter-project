import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _apiService.getOrders();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load orders';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> placeOrder(Order order) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.createOrder(order);
      if (success) {
        await loadOrders();
        return true;
      }
      _error = 'Failed to place order';
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

  double getTotalSpent() {
    return _orders.fold(0, (sum, order) => sum + order.totalPrice);
  }

  int getOrderCount() {
    return _orders.length;
  }
}
