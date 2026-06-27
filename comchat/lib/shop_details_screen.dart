import 'package:comchat/models/shop.dart';
import 'package:comchat/product_list.dart';
import 'package:comchat/repositories/shop_repository.dart';
import 'package:comchat/widgets/business_status_ad_card.dart';
import 'package:flutter/material.dart';

class ShopDetailsScreen extends StatefulWidget {
  final Shop shop;

  const ShopDetailsScreen({super.key, required this.shop});

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  late Shop _shop;
  late final TextEditingController _statusTextController;
  late final TextEditingController _musicUrlController;
  double _duration = 30;
  int _quantity = 1;
  String _deliveryMethod = 'Delivery';

  @override
  void initState() {
    super.initState();
    _shop = widget.shop;
    _statusTextController = TextEditingController(text: _shop.statusText ?? '');
    _musicUrlController = TextEditingController(
      text: _shop.statusMusicUrl ?? '',
    );
    _duration = (_shop.statusDurationSeconds ?? 30).toDouble();
  }

  @override
  void dispose() {
    _statusTextController.dispose();
    _musicUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveStatusAd() async {
    final updatedShop = _shop.copyWith(
      statusText: _statusTextController.text.trim(),
      statusDurationSeconds: _duration.toInt(),
      statusMusicUrl: _musicUrlController.text.trim(),
      isStatusAdActive: true,
    );

    await ShopRepository().updateShop(updatedShop);
    setState(() => _shop = updatedShop);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Weekly special saved successfully.')),
    );
  }

  Future<void> _openStatusAdEditor() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create weekly special'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _statusTextController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Special message',
                    hintText: 'Fresh lunch deals all week long',
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Duration: ${_duration.toInt()} seconds',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Slider(
                  value: _duration,
                  min: 30,
                  max: 60,
                  divisions: 30,
                  label: '${_duration.toInt()}s',
                  onChanged: (value) => setState(() => _duration = value),
                ),
                TextField(
                  controller: _musicUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Background music URL',
                    hintText: 'https://example.com/song.mp3',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _saveStatusAd,
              child: const Text('Save special'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openOrderSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final total = 95.0 * _quantity;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Place your order',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _shop.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _shop.statusText ?? 'Today\'s special is ready to order.',
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Quantity'),
                      const Spacer(),
                      IconButton(
                        onPressed: () => setSheetState(
                          () => _quantity = (_quantity > 1 ? _quantity - 1 : 1),
                        ),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$_quantity'),
                      IconButton(
                        onPressed: () =>
                            setSheetState(() => _quantity = _quantity + 1),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _deliveryMethod,
                    decoration: const InputDecoration(
                      labelText: 'Delivery method',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Delivery',
                        child: Text('Delivery'),
                      ),
                      DropdownMenuItem(value: 'Pickup', child: Text('Pickup')),
                    ],
                    onChanged: (value) => setSheetState(
                      () => _deliveryMethod = value ?? 'Delivery',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.delivery_dining,
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(width: 8),
                      Text('Fast $_deliveryMethod • ${_shop.address}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Total: R${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Order placed successfully for $_quantity item(s)!',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Confirm order'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_shop.name),
        actions: [
          IconButton(
            onPressed: _openStatusAdEditor,
            icon: const Icon(Icons.campaign),
            tooltip: 'Create weekly special',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_shop.imageUrls.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _shop.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.network(
                        _shop.imageUrls[index],
                        width: MediaQuery.of(context).size.width * 0.8,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_shop.name, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      Text(
                        _shop.rating.toString(),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(width: 16),
                      Text(_shop.category, style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _shop.statusText ??
                        'Fresh meals and daily specials waiting for you.',
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openOrderSheet,
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Order now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openStatusAdEditor,
                    icon: const Icon(Icons.campaign),
                    label: const Text('Create weekly special'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_shop.isStatusAdActive) ...[
              BusinessStatusAdCard(shop: _shop),
              const SizedBox(height: 16),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Featured meal', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    _shop.statusText ??
                        'Try today\'s special and enjoy a fresh meal from ${_shop.name}.',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  if (_shop.weeklySpecialPrice != null)
                    Text(
                      'Budget recommendation: R${_shop.weeklySpecialPrice!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Address', style: theme.textTheme.titleLarge),
            Text(_shop.address, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            Text('Contact', style: theme.textTheme.titleLarge),
            Text(_shop.contact, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            Text('Hours', style: theme.textTheme.titleLarge),
            Text(
              '${_shop.openingTime} - ${_shop.closingTime}',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text('Products', style: theme.textTheme.titleLarge),
            const ProductList(),
          ],
        ),
      ),
    );
  }
}
