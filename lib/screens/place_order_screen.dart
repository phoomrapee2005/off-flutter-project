import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class PlaceOrderScreen extends StatefulWidget {
  const PlaceOrderScreen({super.key});

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();

  String _shippingType = 'normal';
  double _shippingFee = 50;

  @override
  void initState() {
    super.initState();
    // Auto-fill user data if logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      if (user != null) {
        setState(() {
          _nameController.text = '${user.firstName} ${user.lastName}';
          _phoneController.text = user.phone;
          _addressController.text = user.address;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _updateShippingFee(String? type) {
    setState(() {
      _shippingType = type ?? 'normal';
      _shippingFee = _shippingType == 'normal' ? 50 : 100;
    });
  }

  Future<void> _placeOrder(BuildContext context, CartProvider cartProvider) async {
    if (!_formKey.currentState!.validate()) return;
    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    // Verify stock
    for (var item in cartProvider.items) {
      if (item.quantity > item.product.quantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Insufficient stock for ${item.product.name}')),
        );
        return;
      }
    }

    final itemsTotal = cartProvider.totalAmount;
    final totalPrice = itemsTotal + _shippingFee;

    final order = Order(
      id: const Uuid().v4(),
      items: cartProvider.items.map((item) => CartItem(
        product: item.product,
        quantity: item.quantity,
      )).toList(),
      customerName: _nameController.text,
      customerPhone: _phoneController.text,
      address: _addressController.text,
      postalCode: _postalCodeController.text,
      shippingType: _shippingType,
      shippingFee: _shippingFee,
      totalPrice: totalPrice,
      orderDate: DateTime.now(),
      paymentMethod: 'bank_transfer',
      status: 'pending',
    );

    // Update stock in database
    for (var item in cartProvider.items) {
      final updatedProduct = item.product.copyWith(
        quantity: item.product.quantity - item.quantity,
      );
      await productProvider.updateProduct(updatedProduct);
    }

    if (!context.mounted) return;
    await Provider.of<OrderProvider>(context, listen: false).placeOrder(order);
    cartProvider.clearCart();

    if (context.mounted) {
      _showSuccessDialog(context, totalPrice);
    }
  }

  void _showSuccessDialog(BuildContext context, double totalPrice) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80)
                .animate()
                .scale(duration: 500.ms, curve: Curves.bounceOut),
            const SizedBox(height: 24),
            const Text(
              'Order Placed!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1A1C23)),
            ),
            const SizedBox(height: 12),
            const Text('Your gaming gear is on the way.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Total: ${NumberFormat.currency(locale: "en_US", symbol: "฿").format(totalPrice)}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1A1C23)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('BACK TO HOME'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '฿');
    final cartProvider = Provider.of<CartProvider>(context);
    final itemsTotal = cartProvider.totalAmount;
    final totalPrice = itemsTotal + _shippingFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSectionHeader('Shipping Address', Icons.location_on_rounded),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
              ),
              validator: (v) => v!.isEmpty ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined, size: 20),
              ),
              validator: (v) => v!.isEmpty ? 'Please enter phone number' : null,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address Detail',
                prefixIcon: Icon(Icons.home_outlined, size: 20),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'Please enter address' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _postalCodeController,
              decoration: const InputDecoration(
                labelText: 'Postal Code',
                prefixIcon: Icon(Icons.pin_drop_outlined, size: 20),
              ),
              validator: (v) => v!.isEmpty ? 'Please enter postal code' : null,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 40),

            _buildSectionHeader('Shipping Method', Icons.local_shipping_rounded),
            const SizedBox(height: 20),
            _buildShippingOption('normal', 'Standard Delivery', '2-3 days', 50),
            _buildShippingOption('express', 'Express Delivery', '1 day', 100),
            
            const SizedBox(height: 40),
            _buildSectionHeader('Order Summary', Icons.receipt_long_rounded),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF1F3F5)),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Items Total', currencyFormat.format(itemsTotal)),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Shipping Fee', currencyFormat.format(_shippingFee)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: Color(0xFFF1F3F5)),
                  ),
                  _buildSummaryRow(
                    'Grand Total',
                    currencyFormat.format(totalPrice),
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _placeOrder(context, cartProvider),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: const Color(0xFF1A1C23),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text(
                  'CONFIRM ORDER',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF4361EE)),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A1C23), letterSpacing: -0.5),
        ),
      ],
    );
  }

  Widget _buildShippingOption(String value, String title, String subtitle, double fee) {
    final isSelected = _shippingType == value;
    
    return GestureDetector(
      onTap: () => _updateShippingFee(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1C23) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFF1F3F5),
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ] : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isSelected ? Colors.white : Colors.grey[400],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: TextStyle(
                      fontWeight: FontWeight.w800, 
                      color: isSelected ? Colors.white : const Color(0xFF1A1C23)
                    )
                  ),
                  Text(
                    subtitle, 
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey[500], 
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    )
                  ),
                ],
              ),
            ),
            Text(
              '฿${fee.toInt()}',
              style: TextStyle(
                fontWeight: FontWeight.w900, 
                fontSize: 16,
                color: isSelected ? Colors.white : const Color(0xFF4361EE)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w500,
            color: isTotal ? const Color(0xFF1A1C23) : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 22 : 16,
            fontWeight: FontWeight.w900,
            color: isTotal ? const Color(0xFF1A1C23) : const Color(0xFF1A1C23),
          ),
        ),
      ],
    );
  }
}
