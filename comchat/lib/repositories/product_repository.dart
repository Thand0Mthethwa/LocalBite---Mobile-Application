import 'package:comchat/models/product.dart';

class ProductRepository {
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Product 1',
      description: 'This is product 1',
      price: 100.0,
    ),
    Product(
      id: '2',
      name: 'Product 2',
      description: 'This is product 2',
      price: 200.0,
    ),
    Product(
      id: '3',
      name: 'Product 3',
      description: 'This is product 3',
      price: 300.0,
    ),
  ];

  Stream<List<Product>> getProducts() {
    return Stream.value(_products);
  }
}
