import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/cart_service.dart';
import 'orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final cart = context.read<CartService>();
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang Anda masih kosong.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ApiService().createOrder(
        items: cart.items
            .map((item) => {'productId': item.product.id, 'quantity': item.quantity})
            .toList(growable: false),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        notes: _notesController.text.trim(),
      );
      cart.clear();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const OrdersScreen(successMessage: 'Pesanan berhasil dibuat.'),
        ),
        (route) => route.isFirst,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Alamat pengiriman', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            TextFormField(
              controller: _addressController,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Alamat lengkap', prefixIcon: Icon(Icons.location_on_outlined)),
              validator: (value) => (value?.trim().length ?? 0) >= 5
                  ? null
                  : 'Masukkan alamat pengiriman (minimal 5 karakter).',
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Nomor telepon', prefixIcon: Icon(Icons.phone_outlined)),
              validator: (value) => (value?.trim().length ?? 0) >= 6
                  ? null
                  : 'Masukkan nomor telepon yang valid.',
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Catatan (opsional)', prefixIcon: Icon(Icons.notes_outlined)),
            ),
            const SizedBox(height: 26),
            Text('Ringkasan pesanan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...cart.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Expanded(child: Text('${item.product.name} × ${item.quantity}')),
                    Text(_formatCurrency(item.subtotal)),
                  ],
                ),
              ),
            ),
            const Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_formatCurrency(cart.total),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
              child: _loading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Buat Pesanan'),
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
