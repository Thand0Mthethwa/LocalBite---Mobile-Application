import 'package:comchat/models/product.dart';
import 'package:comchat/repositories/product_repository.dart';
import 'package:flutter/material.dart';

class ProductList extends StatelessWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context) {
    final productRepository = ProductRepository();
    return StreamBuilder<List<Product>>(
      stream: productRepository.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No products found.'));
        }

        final products = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(product.name),
                subtitle: Text(product.description),
                trailing: Text('${product.currency} ${product.price}'),
              ),
            );
          },
        );
      },
    );
  }
}
