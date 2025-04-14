import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/meal.dart';
import 'package:flutter/material.dart';

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

  // Local mapping of add-on names to icons
  final Map<String, IconData> addOnIcons = {
    'Side Salad': Icons.local_dining,
    'Lemon Butter Sauce': Icons.local_bar,
    'Extra Hummus': Icons.local_dining,
    'Extra Rice': Icons.rice_bowl,
    'Extra Sauce': Icons.local_bar,
  };

  // Default icon for add-ons without a specific icon
  final IconData defaultAddOnIcon = Icons.fastfood;

  // Local mapping of ingredient names to icons
  final Map<String, IconData> ingredientIcons = {
    'salmon': Icons.set_meal,
    'rosemary': Icons.local_florist,
    'thyme': Icons.local_florist,
    'garlic': Icons.local_dining,
    'butter': Icons.local_dining,
    'potatoes': Icons.local_dining,
    'green beans': Icons.local_dining,
    'quinoa': Icons.rice_bowl,
    'avocado': Icons.local_dining,
    'chickpeas': Icons.local_dining,
    'spinach': Icons.local_dining,
    'carrots': Icons.local_dining,
    'chicken': Icons.local_dining,
    'tomato': Icons.local_dining,
    'onion': Icons.local_dining,
    'spices': Icons.local_dining,
    'salt': Icons.local_dining,
    'peppers': Icons.local_dining,
  };

  // Default icon for ingredients without a specific icon
  final IconData defaultIngredientIcon = Icons.local_dining;

  @override
  void initState() {
    super.initState();
    // Initialize add-ons selection and quantities
    for (var addon in widget.meal.addons ?? []) {
      selectedAddOns[addon.name] = addon.isRequired ?? false;
      addOnQuantities[addon.name] = addon.isRequired ?? false ? 1 : 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultImage = widget.meal.images.firstWhere(
      (image) => image.defaultImage,
      orElse: () => widget.meal.images.first,
    );

    // Calculate prices
    double basePrice = widget.meal.price * quantity;
    double addOnPrice = widget.meal.addons
            ?.where((addon) => selectedAddOns[addon.name] == true)
            .fold<double>(
                0.0,
                (sum, addon) =>
                    sum + (addon.price * (addOnQuantities[addon.name] ?? 0))) ??
        0.0;
    double totalPrice = basePrice + addOnPrice;

    // Get selected add-ons for display in the bottom bar
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
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {
                  // Add favorite functionality later
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'meal-image-${widget.meal.id}',
                child: Image.network(
                  defaultImage.secureUrl,
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
                  // Category Chip
                  Chip(
                    label: const Text('Burger'), // Hardcoded until backend provides category
                    backgroundColor: AppColor.secondoryColor,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  // Name
                  Text(
                    widget.meal.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColor.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Rating, Delivery Fee, Preparation Time
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppColor.secondoryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            widget.meal.ratings?.average.toString() ?? 'N/A',
                            style: TextStyle(
                              color: AppColor.secondoryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.delivery_dining,
                            color: AppColor.secondoryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '80 birr', // Hardcoded until backend provides deliveryFee
                            style: TextStyle(
                              color: AppColor.secondoryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
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
                  // Description
                  Text(
                    widget.meal.description ?? 'No description available',
                    style: TextStyle(
                      color: AppColor.subTextColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Calories
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
                  // Spice Level
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
                  // Preparation Time (Repeated)
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
                  // Add-Ons
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
                              ? null // Disable interaction if required
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
                          secondary: Icon(
                            addOnIcons[addon.name] ?? defaultAddOnIcon,
                            color: AppColor.primaryColor,
                            size: 30,
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
                  // Ingredients
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
                        final isAllergen = widget.meal.allergens?.contains(ingredient.name.toLowerCase()) ?? false;
                        return Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200],
                              ),
                              child: Icon(
                                ingredientIcons[ingredient.name.toLowerCase()] ??
                                    defaultIngredientIcon,
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
                            if (isAllergen)
                              Text(
                                '(Allergy)',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColor.subTextColor,
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display selected add-ons with quantities
            if (selectedAddOnsList != null && selectedAddOnsList.isNotEmpty)
              ...selectedAddOnsList.map((addon) {
                return Row(
                  children: [
                    // Add-on icon
                    Icon(
                      addOnIcons[addon.name] ?? defaultAddOnIcon,
                      size: 30,
                      color: AppColor.primaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    // Add-on name and price
                    Expanded(
                      child: Text(
                        '${addon.name} ${addon.price.toStringAsFixed(0)}${widget.meal.currency}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColor.primaryTextColor,
                        ),
                      ),
                    ),
                    // Quantity controls for add-on
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.redAccent),
                          onPressed: addOnQuantities[addon.name]! > 0
                              ? () {
                                  setState(() {
                                    addOnQuantities[addon.name] =
                                        addOnQuantities[addon.name]! - 1;
                                    if (addOnQuantities[addon.name] == 0 &&
                                        !(addon.isRequired ?? false)) {
                                      selectedAddOns[addon.name] = false;
                                    }
                                  });
                                }
                              : null,
                        ),
                        Text(
                          '${addOnQuantities[addon.name]}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle,
                              color: Colors.green),
                          onPressed: () {
                            setState(() {
                              addOnQuantities[addon.name] =
                                  addOnQuantities[addon.name]! + 1;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                );
              }).toList(),
            const SizedBox(height: 8),
            // Base price and quantity controls
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${basePrice.toStringAsFixed(0)}${widget.meal.currency}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColor.primaryTextColor,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle,
                          color: Colors.redAccent),
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
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Add to cart functionality later
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32), // Green color from screenshot
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'ADD TO CART',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}