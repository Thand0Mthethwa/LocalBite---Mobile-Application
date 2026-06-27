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
  final String? statusText;
  final int? statusDurationSeconds;
  final String? statusMusicUrl;
  final bool isStatusAdActive;
  final double? weeklySpecialPrice;
  final String? weeklySpecialLabel;

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
    this.statusText,
    this.statusDurationSeconds,
    this.statusMusicUrl,
    this.isStatusAdActive = false,
    this.weeklySpecialPrice,
    this.weeklySpecialLabel,
  });

  Shop copyWith({
    String? id,
    String? name,
    String? address,
    String? contact,
    String? openingTime,
    String? closingTime,
    double? rating,
    List<String>? imageUrls,
    String? category,
    String? statusText,
    int? statusDurationSeconds,
    String? statusMusicUrl,
    bool? isStatusAdActive,
    double? weeklySpecialPrice,
    String? weeklySpecialLabel,
  }) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      contact: contact ?? this.contact,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      rating: rating ?? this.rating,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      statusText: statusText ?? this.statusText,
      statusDurationSeconds:
          statusDurationSeconds ?? this.statusDurationSeconds,
      statusMusicUrl: statusMusicUrl ?? this.statusMusicUrl,
      isStatusAdActive: isStatusAdActive ?? this.isStatusAdActive,
      weeklySpecialPrice: weeklySpecialPrice ?? this.weeklySpecialPrice,
      weeklySpecialLabel: weeklySpecialLabel ?? this.weeklySpecialLabel,
    );
  }

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
      statusText: json['statusText'],
      statusDurationSeconds: json['statusDurationSeconds']?.toInt(),
      statusMusicUrl: json['statusMusicUrl'],
      isStatusAdActive: json['isStatusAdActive'] ?? false,
      weeklySpecialPrice: json['weeklySpecialPrice']?.toDouble(),
      weeklySpecialLabel: json['weeklySpecialLabel'],
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
      'statusText': statusText,
      'statusDurationSeconds': statusDurationSeconds,
      'statusMusicUrl': statusMusicUrl,
      'isStatusAdActive': isStatusAdActive,
      'weeklySpecialPrice': weeklySpecialPrice,
      'weeklySpecialLabel': weeklySpecialLabel,
    };
  }
}
