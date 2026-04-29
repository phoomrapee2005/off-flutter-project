import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/order_provider.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'th_TH', symbol: '฿');
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Order History'),
        centerTitle: true,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF1F3F5)),
                    ),
                    child: Icon(Icons.history_rounded, size: 80, color: Colors.grey[200]),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No orders yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1C23)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your shopping history will appear here.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ).animate().fadeIn();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: orderProvider.orders.length,
            itemBuilder: (context, index) {
              final order = orderProvider.orders[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF1F3F5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Theme(
                  data: theme.copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status).withAlpha(30),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.receipt_long_rounded, color: _getStatusColor(order.status), size: 24),
                    ),
                    title: Text(
                      'Order #${order.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1A1C23)),
                    ),
                    subtitle: Text(
                      dateFormat.format(order.orderDate),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormat.format(order.totalPrice),
                          style: const TextStyle(
                            color: Color(0xFF1A1C23),
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _buildStatusChip(order.status),
                      ],
                    ),
                    children: [
                      const Divider(height: 1, color: Color(0xFFF1F3F5), indent: 20, endIndent: 20),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoSection('Customer Info', [
                              _buildInfoRow('Name', order.customerName),
                              _buildInfoRow('Phone', order.customerPhone),
                              _buildInfoRow('Address', order.address),
                            ]),
                            const SizedBox(height: 20),
                            _buildInfoSection('Shipping Info', [
                              _buildInfoRow('Method', order.shippingType == 'normal' ? 'Standard' : 'Express'),
                              _buildInfoRow('Fee', currencyFormat.format(order.shippingFee)),
                            ]),
                            const SizedBox(height: 20),
                            const Text(
                              'Order Items',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1A1C23)),
                            ),
                            const SizedBox(height: 12),
                            ...order.items.map((item) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.product.name,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                    ),
                                  ),
                                  Text(
                                    'x${item.quantity}',
                                    style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    currencyFormat.format(item.totalPrice),
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                                  ),
                                ],
                              ),
                            )),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9ECEF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Payment Details',
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Bank Transfer', style: TextStyle(fontSize: 13)),
                                      Text(
                                        currencyFormat.format(order.totalPrice),
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1A1C23)),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1C23)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = _getStatusColor(status);
    String text;

    switch (status) {
      case 'pending': text = 'Pending'; break;
      case 'paid': text = 'Paid'; break;
      case 'shipping': text = 'Shipping'; break;
      case 'completed': text = 'Completed'; break;
      default: text = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFFFF9F1C);
      case 'paid': return const Color(0xFF2EC4B6);
      case 'shipping': return const Color(0xFF4361EE);
      case 'completed': return const Color(0xFF20BF55);
      default: return Colors.grey;
    }
  }
}
