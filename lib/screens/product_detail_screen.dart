import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import 'add_product_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '฿');

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_image_${product.id}',
                child: Container(
                  color: const Color(0xFFF1F3F5),
                  child: product.imagePath.isNotEmpty
                      ? (kIsWeb || product.imagePath.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: product.imagePath,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.grey[100]),
                              errorWidget: (context, url, error) => _buildImagePlaceholder(),
                            )
                          : Image.file(
                              File(product.imagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                            ))
                      : _buildImagePlaceholder(),
                ),
              ),
            ),
            actions: [//edit icon
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.black),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddProductScreen(product: product),
                        ),
                      );
                      if (context.mounted) {
                        Provider.of<ProductProvider>(context, listen: false).loadProducts();
                      }
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(context),
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: product.quantity <= 0
                                ? Colors.red[50]
                                : (product.condition == 'new' ? Colors.green[50] : Colors.orange[50]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            product.quantity <= 0 ? 'OUT OF STOCK' : (product.condition == 'new' ? 'มือ 1' : 'มือ 2'),
                            style: TextStyle(
                              color: product.quantity <= 0
                                  ? Colors.red[700]
                                  : (product.condition == 'new' ? Colors.green[700] : Colors.orange[800]),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          'ID: ${product.id.substring(0, 8)}',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ).animate().fadeIn().slideX(),
                    const SizedBox(height: 16),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1C23),
                        letterSpacing: -1,
                      ),
                    ).animate().fadeIn(delay: 100.ms).moveY(begin: 10, end: 0),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          product.brand,
                          style: TextStyle(
                            fontSize: 18,
                            color: const Color(0xFF4361EE),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          product.modelName,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms).moveY(begin: 10, end: 0),
                    const SizedBox(height: 24),
                    
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildSpecTile('Category', product.category, Icons.category_outlined),
                          _buildSpecTile('Stock', '${product.quantity} units', Icons.inventory_2_outlined),
                          _buildSpecTile('Condition', product.condition == 'new' ? 'มือ 1' : 'มือ 2', Icons.info_outline_rounded),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Divider(color: Color(0xFFF1F3F5)),
                    ),
                    
                    const Text(
                      'Seller Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.person_rounded, product.sellerName),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.phone_rounded, product.sellerPhone),
                    
                    const SizedBox(height: 32),
                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.description,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  currencyFormat.format(product.price),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1C23),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                onPressed: product.quantity > 0
                    ? () {
                        Provider.of<CartProvider>(context, listen: false).addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added to cart'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF1A1C23),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: const Color(0xFF1A1C23),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text('ADD TO CART'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecTile(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      width: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F3F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4361EE)),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1A1C23)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1A1C23)),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Icon(Icons.videogame_asset_outlined, size: 80, color: Colors.grey[300]),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Item?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ProductProvider>(context, listen: false).deleteProduct(product.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
