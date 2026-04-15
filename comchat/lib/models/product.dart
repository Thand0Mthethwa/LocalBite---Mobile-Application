class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'ZAR',
  });

  // fromJson
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      currency: json['currency'] ?? 'ZAR',
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
    };
  }
}
