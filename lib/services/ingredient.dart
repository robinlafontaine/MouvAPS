class Ingredient {
  final String name;
  final int quantity;

  Ingredient({
    required this.name,
    required this.quantity,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['ingredient']['name'] as String,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
    };
  }
}
