import 'dart:convert';

import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/meal.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MealDetailsPage extends StatefulWidget {
  final Meal meal;

  const MealDetailsPage({super.key, required this.meal});

  @override
  State<MealDetailsPage> createState() => _MealDetailsPageState();
}

class _MealDetailsPageState extends State<MealDetailsPage> {
  int quantity = 1;
  final Map<String, bool> selectedAddOns = {};
  final Map<String, int> addOnQuantities = {};
  bool isFavorite = false;

  // FontAwesome icons for add-ons (fallback if image is null)
  final Map<String, IconData> addOnIcons = {
    'Side Salad': FontAwesomeIcons.carrot,
    'Lemon Butter Sauce': FontAwesomeIcons.lemon,
    'Extra Hummus': FontAwesomeIcons.bowlRice,
    'Extra Rice': FontAwesomeIcons.seedling,
    'Extra Sauce': FontAwesomeIcons.jar,
  };

  final IconData defaultAddOnIcon = FontAwesomeIcons.utensils;

  // FontAwesome icons for ingredients (fallback if icon is null)
  final Map<String, IconData> ingredientIcons = {
    'salmon': FontAwesomeIcons.fish,
    'rosemary': FontAwesomeIcons.seedling,
    'thyme': FontAwesomeIcons.seedling,
    'garlic': FontAwesomeIcons.seedling,
    'butter': FontAwesomeIcons.cube,
    'potatoes': FontAwesomeIcons.seedling,
    'green beans': FontAwesomeIcons.seedling,
    'quinoa': FontAwesomeIcons.wheatAwn,
    'avocado': FontAwesomeIcons.carrot,
    'chickpeas': FontAwesomeIcons.bowlRice,
    'spinach': FontAwesomeIcons.leaf,
    'carrots': FontAwesomeIcons.carrot,
    'chicken': FontAwesomeIcons.drumstickBite,
    'tomato': FontAwesomeIcons.seedling,
    'onion': FontAwesomeIcons.seedling,
    'spices': FontAwesomeIcons.mortarPestle,
    'salt': FontAwesomeIcons.seedling,
    'peppers': FontAwesomeIcons.pepperHot,
  };

  final IconData defaultIngredientIcon = FontAwesomeIcons.carrot;

  @override
  void initState() {
    super.initState();
    for (var addon in widget.meal.addons ?? []) {
      selectedAddOns[addon.name] = addon.isRequired ?? false;
      addOnQuantities[addon.name] = addon.isRequired ?? false ? 1 : 0;
    }
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteMealIds = prefs.getStringList('favorite_meals') ?? [];
    setState(() {
      isFavorite = favoriteMealIds.contains(widget.meal.id);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteMealIds = prefs.getStringList('favorite_meals') ?? [];

    if (isFavorite) {
      favoriteMealIds.remove(widget.meal.id);
    } else {
      favoriteMealIds.add(widget.meal.id);
    }

    await prefs.setStringList('favorite_meals', favoriteMealIds);
    setState(() {
      isFavorite = !isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? '${widget.meal.name} added to favorites'
              : '${widget.meal.name} removed from favorites',
        ),
      ),
    );
  }

  Future<void> _addToCart() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartItemsJson = prefs.getStringList('cart_items') ?? [];

    final selectedAddOnsList = widget.meal.addons
        ?.where((addon) => selectedAddOns[addon.name] == true)
        .toList();
    final addOnQuantitiesList = selectedAddOnsList
        ?.map((addon) => addOnQuantities[addon.name] ?? 0)
        .toList();

    final cartItem = CartItem(
      meal: widget.meal,
      quantity: quantity,
      selectedAddOns: selectedAddOnsList ?? [],
      addOnQuantities: addOnQuantitiesList ?? [],
    );

    cartItemsJson.add(jsonEncode(cartItem.toJson()));
    await prefs.setStringList('cart_items', cartItemsJson);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.meal.name} added to cart'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = 'https://via.placeholder.com/150';
    if (widget.meal.images.isNotEmpty) {
      final defaultImage = widget.meal.images.firstWhere(
        (image) => image.defaultImage,
        orElse: () => widget.meal.images.first,
      );
      imageUrl = defaultImage.secureUrl;
    }

    double basePrice = widget.meal.price * quantity;
    final selectedAddOnsList = widget.meal.addons
        ?.where((addon) => selectedAddOns[addon.name] == true)
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'meal-image-${widget.meal.id}',
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    label: Text(widget.meal.category ?? 'Unknown'),
                    backgroundColor: AppColor.secondoryColor,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.meal.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColor.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (widget.meal.ratings != null)
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: AppColor.secondoryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              widget.meal.ratings!.average.toString(),
                              style: TextStyle(
                                color: AppColor.secondoryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(width: 12),
                      if (widget.meal.deliveryFee != null)
                        Row(
                          children: [
                            Icon(
                              Icons.delivery_dining,
                              color: AppColor.secondoryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${widget.meal.deliveryFee!.toStringAsFixed(0)} birr',
                              style: TextStyle(
                                color: AppColor.secondoryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(width: 12),
                      if (widget.meal.preparationTime != null)
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: AppColor.secondoryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${widget.meal.preparationTime} min',
                              style: TextStyle(
                                color: AppColor.secondoryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.meal.description ?? 'No description available',
                    style: TextStyle(
                      color: AppColor.subTextColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.meal.calories != null)
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: AppColor.secondoryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Calories: ${widget.meal.calories}',
                          style: TextStyle(
                            color: AppColor.subTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  if (widget.meal.spiceLevel != null)
                    Row(
                      children: [
                        Text(
                          'Spicy: ${widget.meal.spiceLevel}',
                          style: TextStyle(
                            color: AppColor.subTextColor,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.red, Colors.orange, Colors.green],
                                stops: [0.0, 0.5, 1.0],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  if (widget.meal.preparationTime != null)
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: AppColor.secondoryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Preparation Time: ${widget.meal.preparationTime} min',
                          style: TextStyle(
                            color: AppColor.subTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'ADD ONS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColor.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.meal.addons != null && widget.meal.addons!.isNotEmpty)
                    ...widget.meal.addons!.map((addon) {
                      final isRequired = addon.isRequired ?? false;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedAddOns[addon.name] == true
                                ? AppColor.primaryColor
                                : Colors.grey[300]!,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CheckboxListTile(
                          value: selectedAddOns[addon.name] ?? false,
                          onChanged: isRequired
                              ? null
                              : (value) {
                                  setState(() {
                                    selectedAddOns[addon.name] = value ?? false;
                                    addOnQuantities[addon.name] =
                                        value ?? false ? 1 : 0;
                                  });
                                },
                          title: Text(addon.name),
                          subtitle: Text(
                            '${addon.price.toStringAsFixed(0)} ${widget.meal.currency}',
                            style: TextStyle(
                              color: AppColor.subTextColor,
                              fontSize: 12,
                            ),
                          ),
                          secondary: addon.image != null
                              ? Image.network(
                                  addon.image!,
                                  width: 30,
                                  height: 30,
                                  errorBuilder: (context, error, stackTrace) => FaIcon(
                                    addOnIcons[addon.name] ?? defaultAddOnIcon,
                                    color: AppColor.primaryColor,
                                    size: 24,
                                  ),
                                )
                              : FaIcon(
                                  addOnIcons[addon.name] ?? defaultAddOnIcon,
                                  color: AppColor.primaryColor,
                                  size: 24,
                                ),
                          activeColor: AppColor.primaryColor,
                          controlAffinity: ListTileControlAffinity.trailing,
                          dense: true,
                        ),
                      );
                    }).toList()
                  else
                    const Text('No add-ons available'),
                  const SizedBox(height: 16),
                  Text(
                    'INGREDIENTS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColor.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.meal.ingredients != null &&
                      widget.meal.ingredients!.isNotEmpty)
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.start,
                      children: widget.meal.ingredients!.map((ingredient) {
                        final icon = ingredient.icon != null &&
                                ingredientIcons.containsKey(ingredient.icon!.toLowerCase())
                            ? ingredientIcons[ingredient.icon!.toLowerCase()]
                            : ingredientIcons[ingredient.name.toLowerCase()] ??
                                defaultIngredientIcon;
                        return Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200],
                              ),
                              child: FaIcon(
                                icon,
                                color: AppColor.primaryTextColor,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ingredient.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColor.primaryTextColor,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    )
                  else
                    const Text('No ingredients listed'),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Meal Item
            Row(
              children: [
                ClipOval(
                  child: Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    '${basePrice.toStringAsFixed(0)}birr',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primaryTextColor,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.pink[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) quantity--;
                          });
                        },
                      ),
                      Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Selected Add-Ons
            if (selectedAddOnsList != null && selectedAddOnsList.isNotEmpty)
              ...selectedAddOnsList.map((addon) {
                final addOnQuantity = addOnQuantities[addon.name] ?? 0;
                final addOnTotalPrice = addon.price * addOnQuantity;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: addon.image != null
                            ? Image.network(
                                addon.image!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    FaIcon(
                                  addOnIcons[addon.name] ?? defaultAddOnIcon,
                                  color: AppColor.primaryTextColor,
                                  size: 24,
                                ),
                              )
                            : FaIcon(
                                addOnIcons[addon.name] ?? defaultAddOnIcon,
                                color: AppColor.primaryTextColor,
                                size: 24,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          addOnQuantity > 0
                              ? '${addOnTotalPrice.toStringAsFixed(0)}birr'
                              : '0birr',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primaryTextColor,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.pink[100],
                          borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Colors.white),
                                onPressed: addOnQuantity > 0
                                    ? () {
                                        setState(() {
                                          addOnQuantities[addon.name] =
                                              addOnQuantity - 1;
                                          if (addOnQuantities[addon.name] == 0 &&
                                              !(addon.isRequired ?? false)) {
                                            selectedAddOns[addon.name] = false;
                                          }
                                        });
                                      }
                                    : null,
                              ),
                              Text(
                                '$addOnQuantity',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    addOnQuantities[addon.name] = addOnQuantity + 1;
                                    selectedAddOns[addon.name] = true;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            const SizedBox(height: 16),
            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'ADD TO CART',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}