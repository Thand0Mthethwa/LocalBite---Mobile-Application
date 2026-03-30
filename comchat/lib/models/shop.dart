class Shop {
  final String id;
  final String name;
  final String address;
  final String contact;
  final String openingTime;
  final String closingTime;
  final double rating;
  final List<String> imageUrls;
  final String category;

  Shop({
    required this.id,
    required this.name,
    required this.address,
    required this.contact,
    required this.openingTime,
    required this.closingTime,
    required this.rating,
    required this.imageUrls,
    required this.category,
  });

  // fromJson
  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      contact: json['contact'],
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      rating: json['rating'].toDouble(),
      imageUrls: List<String>.from(json['imageUrls']),
      category: json['category'],
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'contact': contact,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'rating': rating,
      'imageUrls': imageUrls,
      'category': category,
    };
  }
}
