import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import 'cart_screen.dart';
import 'detail_screen.dart';
import 'login_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _categories = [
    'Semua kategori',
    'Aksesori',
    'Elektronik',
    'Fashion',
    'Rumah Tangga',
  ];
  final _searchController = TextEditingController();
  final _api = ApiService();
  late Future<List<Product>> _productsFuture;
  String _category = '';
  String _search = '';

  @override
  void initState() {
    super.initState();
    _productsFuture = _api.getProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    setState(() {
      _productsFuture = _api.getProducts(search: _search, kategori: _category);
    });
  }

  Future<void> _logout() async {
    await AuthService().logout();
    CartService.instance.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Toko Online',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Pesanan saya',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const OrdersScreen()),
            ),
            icon: const Icon(Icons.receipt_long_outlined),
          ),
          IconButton(
            tooltip: 'Profil',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            ),
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: 'Keluar',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    _search = value.trim();
                    _loadProducts();
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      tooltip: 'Cari',
                      onPressed: () {
                        _search = _searchController.text.trim();
                        _loadProducts();
                      },
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _category.isEmpty ? _categories.first : _category,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(Icons.tune),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  items: _categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    _category = value == _categories.first ? '' : value ?? '';
                    _loadProducts();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _LoadError(
                    onRetry: _loadProducts,
                    message: snapshot.error.toString(),
                  );
                }
                final products = snapshot.data ?? const <Product>[];
                if (products.isEmpty) {
                  return const Center(child: Text('Produk tidak ditemukan.'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.66,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) =>
                      _ProductCard(product: products[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: context.watch<CartService>(),
        builder: (context, child) {
          final cart = context.read<CartService>();
          if (cart.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const CartScreen())),
            icon: const Icon(Icons.shopping_cart_outlined),
            label: Text('Keranjang (${cart.itemCount})'),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DetailScreen(productId: product.id),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                product.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFFE8EAF6),
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                      color: Colors.indigo,
                    ),
                  ),
                ),
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: Colors.indigo),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _rupiah(product.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  Text(
                    'Stok ${product.stock}',
                    style: Theme.of(context).textTheme.bodySmall,
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

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry, required this.message});

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: Colors.indigo,
            ),
            const SizedBox(height: 12),
            const Text(
              'Produk gagal dimuat. Periksa koneksi server Anda.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

String _rupiah(num amount) {
  final value = amount.round().toString();
  final formatted = value.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (match) => '${match[1]}.',
  );
  return 'Rp$formatted';
}
