class MealImage {
  final String secureUrl;
  final String publicId;
  final bool defaultImage;

  MealImage({
    required this.secureUrl,
    required this.publicId,
    required this.defaultImage,
  });
}

class AddOn {
  final String name;
  final double price;
  final bool? isRequired;
  final String? image; // New field for add-on image

  AddOn({
    required this.name,
    required this.price,
    this.isRequired,
    this.image,
  });
}

class Ingredient {
  final String name;
  final String? icon; // New field for ingredient icon

  Ingredient({
    required this.name,
    this.icon,
  });
}

class Ratings {
  final double average;
  final int count;

  Ratings({
    required this.average,
    required this.count,
  });
}

class Meal {
  final String id;
  final String name;
  final String? category; // New field for user-friendly category
  final double price;
  final String currency;
  final List<MealImage> images;
  final bool availability;
  final String? description;
  final Ratings? ratings;
  final int? preparationTime;
  final int? calories;
  final String? spiceLevel;
  final List<AddOn>? addons;
  final List<Ingredient>? ingredients;
  final double? deliveryFee; // New field for delivery fee
  final bool? isFavorited; // New field for favorite status

  Meal({
    required this.id,
    required this.name,
    this.category,
    required this.price,
    required this.currency,
    required this.images,
    required this.availability,
    this.description,
    this.ratings,
    this.preparationTime,
    this.calories,
    this.spiceLevel,
    this.addons,
    this.ingredients,
    this.deliveryFee,
    this.isFavorited,
  });
}