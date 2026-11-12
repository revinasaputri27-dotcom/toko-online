import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.productId});

  final String productId;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _api = ApiService();
  late Future<Product> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = _api.getProduct(widget.productId);
  }

  void _retry() => setState(() => _productFuture = _api.getProduct(widget.productId));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Detail produk gagal dimuat.'),
                  TextButton(onPressed: _retry, child: const Text('Coba lagi')),
                ],
              ),
            );
          }
          final product = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Color(0xFFE8EAF6),
                      child: Center(child: Icon(Icons.image_not_supported_outlined, size: 56)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(product.category, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.indigo)),
              const SizedBox(height: 6),
              Text(product.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_formatCurrency(product.price), style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 12),
              Text('Stok tersedia: ${product.stock}'),
              const SizedBox(height: 20),
              Text('Deskripsi', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(product.description, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: product.stock == 0
                    ? null
                    : () {
                        context.read<CartService>().add(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${product.name} ditambahkan ke keranjang.')),
                        );
                      },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Tambah ke Keranjang'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ],
          );
        },
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
