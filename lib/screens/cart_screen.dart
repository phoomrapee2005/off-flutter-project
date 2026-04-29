import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import 'place_order_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '฿');
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('My Cart'),
        centerTitle: true,
      ),
      body: cart.items.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return _CartItemTile(item: item, currencyFormat: currencyFormat);
                    },
                  ),
                ),
                _buildSummary(context, cart, currencyFormat, theme),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildSummary(BuildContext context, CartProvider cart, NumberFormat currencyFormat, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                currencyFormat.format(cart.totalAmount),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1A1C23)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PlaceOrderScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: const Color(0xFF1A1C23),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: const Text('PROCEED TO CHECKOUT', style: TextStyle(letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final NumberFormat currencyFormat;

  const _CartItemTile({required this.item, required this.currencyFormat});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F3F5)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 90,
              height: 90,
              color: const Color(0xFFF8F9FA),
              child: item.product.imagePath.isNotEmpty
                  ? (kIsWeb || item.product.imagePath.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: item.product.imagePath,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(item.product.imagePath),
                          fit: BoxFit.cover,
                        ))
                  : const Icon(Icons.videogame_asset_outlined, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1A1C23)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormat.format(item.product.price),
                  style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildQtyBtn(Icons.remove, () {
                            cart.updateQuantity(item.product.id, item.quantity - 1);
                          }),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                            ),
                          ),
                          _buildQtyBtn(Icons.add, () {
                            cart.updateQuantity(item.product.id, item.quantity + 1);
                          }),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 22),
                      onPressed: () => cart.removeFromCart(item.product.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 16, color: const Color(0xFF1A1C23)),
      ),
    );
  }
}
