import 'package:flutter/material.dart';

import '../models/order.dart';
import '../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, this.successMessage});

  final String? successMessage;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _api = ApiService();
  late Future<List<Order>> _ordersFuture;
  String _selectedStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _ordersFuture = _api.getOrders();
    if (widget.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(widget.successMessage!)));
      });
    }
  }

  void _refresh() => setState(() => _ordersFuture = _api.getOrders());

  Future<void> _confirmReceived(String orderId) async {
    try {
      await _api.confirmOrderReceived(orderId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil ditandai diterima.')),
      );
      _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.indigo,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Pesanan gagal dimuat.',
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      snapshot.error.toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    TextButton(
                      onPressed: _refresh,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }
          final orders = snapshot.data ?? const <Order>[];
          final filteredOrders = _selectedStatus == 'Semua'
              ? orders
              : orders
                    .where(
                      (order) =>
                          order.status.trim().toLowerCase() ==
                          _selectedStatus.toLowerCase(),
                    )
                    .toList(growable: false);
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Semua', 'Diproses', 'Dikirim', 'Diterima'].map((
                      status,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: _selectedStatus == status,
                          onSelected: (_) =>
                              setState(() => _selectedStatus = status),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                if (filteredOrders.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.indigo,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _selectedStatus == 'Semua'
                              ? 'Belum ada pesanan.'
                              : 'Belum ada pesanan dengan status $_selectedStatus.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredOrders.map(
                    (order) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _OrderCard(
                        order: order,
                        onReceived: order.status == 'Dikirim'
                            ? () => _confirmReceived(order.id)
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, this.onReceived});

  final Order order;
  final VoidCallback? onReceived;

  @override
  Widget build(BuildContext context) {
    final date = order.createdAt == null
        ? '-'
        : '${order.createdAt!.day.toString().padLeft(2, '0')}/'
              '${order.createdAt!.month.toString().padLeft(2, '0')}/'
              '${order.createdAt!.year}';
    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE8EAF6),
          child: Icon(Icons.receipt_long_outlined, color: Colors.indigo),
        ),
        title: Text(
          'Pesanan #${order.id}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$date · ${order.status}'),
        trailing: Text(
          _formatCurrency(order.total),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        children: [
          const Divider(),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(child: Text('${item.name} × ${item.quantity}')),
                  Text(_formatCurrency(item.price * item.quantity)),
                ],
              ),
            ),
          ),
          if (order.address.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Dikirim ke: ${order.address}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
          if (order.phone.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Telepon: ${order.phone}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (onReceived != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onReceived,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Tandai Diterima'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatCurrency(num amount) {
  final formatted = amount.round().toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (match) => '${match[1]}.',
  );
  return 'Rp$formatted';
}
