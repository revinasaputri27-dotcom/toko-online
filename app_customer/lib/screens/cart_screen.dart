import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../services/cart_service.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: AnimatedBuilder(
        animation: context.watch<CartService>(),
        builder: (context, child) {
          final cart = context.read<CartService>();
          if (cart.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.remove_shopping_cart_outlined, size: 64, color: Colors.indigo),
                  SizedBox(height: 12),
                  Text('Keranjang Anda masih kosong.'),
                ],
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _CartRow(item: cart.items[index]),
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(fontSize: 16)),
                          Text(_formatCurrency(cart.total),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      FilledButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const CheckoutScreen()),
                        ),
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                        child: const Text('Lanjut ke Checkout'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartService>();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 76,
                height: 76,
                child: Image.network(
                  item.product.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const ColoredBox(
                    color: Color(0xFFE8EAF6),
                    child: Icon(Icons.shopping_bag_outlined, color: Colors.indigo),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  Text(_formatCurrency(item.product.price),
                      style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => cart.decrease(item.product.id),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('${item.quantity}'),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: item.quantity < item.product.stock ? () => cart.add(item.product) : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Hapus item',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => cart.remove(item.product.id),
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
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
}

String _formatCurrency(num amount) {
  final formatted = amount.round().toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (match) => '${match[1]}.',
      );
  return 'Rp$formatted';
}
