import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'add_product_screen.dart';
import 'order_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'All',
    'มือ 1',
    'มือ 2',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              floating: true,
              snap: true,
              expandedHeight: 160,
              backgroundColor: theme.colorScheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Click & Clack',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: theme.colorScheme.primary,
                                    letterSpacing: -1,
                                  ),
                                ),
                                Text(
                                  'Discover Gaming gear',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _ActionButton(
                                icon: Icons.history_rounded,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _CartButton(),
                              const SizedBox(width: 12),
                              _ActionButton(
                                icon: Icons.logout_rounded,
                                onPressed: () {
                                  Provider.of<AuthProvider>(context, listen: false).logout();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                      prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: _searchQuery.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey.withAlpha(20)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: theme.colorScheme.primary.withAlpha(50)),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
          body: Column(
            children: [
              _buildFilterList(),
              const SizedBox(height: 12),
              Expanded(
                child: Consumer<ProductProvider>(
                  builder: (context, productProvider, _) {
                    if (productProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var filteredProducts = productProvider.searchProducts(_searchQuery);
                    if (_selectedFilter == 'มือ 1') {
                      filteredProducts = filteredProducts
                          .where((p) => p.condition == 'new')
                          .toList();
                    } else if (_selectedFilter == 'มือ 2') {
                      filteredProducts = filteredProducts
                          .where((p) => p.condition == 'used')
                          .toList();
                    }

                    if (filteredProducts.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: () => productProvider.loadProducts(),
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          return _ProductCard(
                            product: filteredProducts[index],
                            index: index,
                          ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).moveY(begin: 20, end: 0);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
          if (!context.mounted) return;
          Provider.of<ProductProvider>(context, listen: false).loadProducts();
        },
        label: const Text('New Post'),
        icon: const Icon(Icons.add_rounded),
        elevation: 4,
      ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildFilterList() {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          final theme = Theme.of(context);
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              side: BorderSide(
                color: isSelected ? Colors.transparent : Colors.grey.withAlpha(30),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 20),
          Text(
            'No results found',
            style: TextStyle(fontSize: 18, color: Colors.grey[400], fontWeight: FontWeight.bold),
          ),
        ],
      ).animate().fadeIn(),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withAlpha(20)),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87, size: 22),
        onPressed: onPressed,
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            _ActionButton(
              icon: Icons.shopping_basket_rounded,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ),
            ),
            if (cart.itemCount > 0)
              Positioned(
                right: -5,
                top: -5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4361EE),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 22,
                    minHeight: 22,
                  ),
                  child: Text(
                    '${cart.itemCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().scale().shake(),
              ),
          ],
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final int index;

  const _ProductCard({required this.product, required this.index});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '฿');
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'product_image_${product.id}',
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F5),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        image: product.imagePath.isNotEmpty
                            ? DecorationImage(
                                image: (kIsWeb || product.imagePath.startsWith('http')
                                    ? CachedNetworkImageProvider(product.imagePath)
                                    : FileImage(File(product.imagePath))) as ImageProvider,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: product.imagePath.isEmpty ? _buildPlaceholder() : null,
                    ),
                  ),
                  if (product.quantity <= 0)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(80),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: const Center(
                        child: Text(
                          'SOLD OUT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(220),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.condition == 'new' ? 'มือ 1' : 'มือ 2',
                        style: TextStyle(
                          color: product.condition == 'new' ? Colors.green[700] : Colors.orange[800],
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF1A1C23),
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.brand,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currencyFormat.format(product.price),
                        style: const TextStyle(
                          color: Color(0xFF1A1C23),
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(Icons.videogame_asset_outlined, color: Colors.grey[300], size: 40),
    );
  }
}
