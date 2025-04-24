class MealImage {
  final String secureUrl;
  final String publicId;
  final bool defaultImage;

  MealImage({
    required this.secureUrl,
    required this.publicId,
    required this.defaultImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'secureUrl': secureUrl,
      'publicId': publicId,
      'defaultImage': defaultImage,
    };
  }

  factory MealImage.fromJson(Map<String, dynamic> json) {
    return MealImage(
      secureUrl: json['secureUrl'],
      publicId: json['publicId'],
      defaultImage: json['defaultImage'],
    );
  }
}

class AddOn {
  final String name;
  final double price;
  final bool? isRequired;
  final String? image;

  AddOn({
    required this.name,
    required this.price,
    this.isRequired,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'isRequired': isRequired,
      'image': image,
    };
  }

  factory AddOn.fromJson(Map<String, dynamic> json) {
    return AddOn(
      name: json['name'],
      price: json['price'],
      isRequired: json['isRequired'],
      image: json['image'],
    );
  }
}

class Ingredient {
  final String name;
  final String? icon;

  Ingredient({
    required this.name,
    this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
    };
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'],
      icon: json['icon'],
    );
  }
}

class Ratings {
  final double average;
  final int count;

  Ratings({
    required this.average,
    required this.count,
  });

  Map<String, dynamic> toJson() {
    return {
      'average': average,
      'count': count,
    };
  }

  factory Ratings.fromJson(Map<String, dynamic> json) {
    return Ratings(
      average: json['average'],
      count: json['count'],
    );
  }
}

class Meal {
  final String id;
  final String name;
  final String? category;
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
  final double? deliveryFee;
  final bool? isFavorited;
  final List<String>? categories;
  final int? estimatedDeliveryTime;
  final List<String>? allergens;

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
    this.categories,
    this.estimatedDeliveryTime,
    this.allergens,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'currency': currency,
      'images': images.map((image) => image.toJson()).toList(),
      'availability': availability,
      'description': description,
      'ratings': ratings?.toJson(),
      'preparationTime': preparationTime,
      'calories': calories,
      'spiceLevel': spiceLevel,
      'addons': addons?.map((addon) => addon.toJson()).toList(),
      'ingredients': ingredients?.map((ingredient) => ingredient.toJson()).toList(),
      'deliveryFee': deliveryFee,
      'isFavorited': isFavorited,
      'categories': categories,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'allergens': allergens,
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: json['price'],
      currency: json['currency'],
      images: (json['images'] as List)
          .map((imageJson) => MealImage.fromJson(imageJson))
          .toList(),
      availability: json['availability'],
      description: json['description'],
      ratings: json['ratings'] != null ? Ratings.fromJson(json['ratings']) : null,
      preparationTime: json['preparationTime'],
      calories: json['calories'],
      spiceLevel: json['spiceLevel'],
      addons: json['addons'] != null
          ? (json['addons'] as List)
              .map((addonJson) => AddOn.fromJson(addonJson))
              .toList()
          : null,
      ingredients: json['ingredients'] != null
          ? (json['ingredients'] as List)
              .map((ingredientJson) => Ingredient.fromJson(ingredientJson))
              .toList()
          : null,
      deliveryFee: json['deliveryFee'],
      isFavorited: json['isFavorited'],
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : null,
      estimatedDeliveryTime: json['estimatedDeliveryTime'],
      allergens: json['allergens'] != null
          ? List<String>.from(json['allergens'])
          : null,
    );
  }
}