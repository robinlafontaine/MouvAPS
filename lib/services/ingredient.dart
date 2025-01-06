class Ingredient {
  final String name;
  final int quantity;
  final String imageUrl;

  Ingredient({
    required this.name,
    required this.quantity,
    required this.imageUrl,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['ingredient']['name'] as String,
      quantity: json['quantity'] as int,
      imageUrl: json['ingredient']['image_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'image_url': imageUrl,
    };
  }

  Ingredient copyWith({
    String? name,
    int? quantity,
    String? imageUrl,
  }) {
    return Ingredient(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
