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
  int addOnQuantity = 0;
  final Map<String, bool> selectedAddOns = {};

  @override
  void initState() {
    super.initState();
    // Initialize add-ons selection
    for (var addon in widget.meal.addons ?? []) {
      selectedAddOns[addon.name] = addon.isRequired ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultImage = widget.meal.images.firstWhere(
      (image) => image.defaultImage,
      orElse: () => widget.meal.images.first,
    );

    // Calculate total price
    double basePrice = widget.meal.price * quantity;
    double addOnPrice = widget.meal.addons
            ?.where((addon) => selectedAddOns[addon.name] == true)
            .fold(0.0, (sum, addon) => sum! + (addon.price * addOnQuantity)) ??
        0.0;
    double totalPrice = basePrice + addOnPrice;

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
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
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
                    style:  TextStyle(
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
                      return CheckboxListTile(
                        value: selectedAddOns[addon.name] ?? false,
                        onChanged: (value) {
                          setState(() {
                            selectedAddOns[addon.name] = value ?? false;
                          });
                        },
                        title: Text(addon.name),
                        subtitle: Text('${addon.price} ${widget.meal.currency}'),
                        secondary: addon.image != null
                            ? Image.network(
                                addon.image!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood),
                              )
                            : const Icon(Icons.fastfood),
                        controlAffinity: ListTileControlAffinity.trailing,
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
                  if (widget.meal.ingredients != null && widget.meal.ingredients!.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.meal.ingredients!.map((ingredient) {
                        return Chip(
                          label: Text(ingredient.name), // Use ingredient.name instead of ingredient
                          avatar: ingredient.icon != null
                              ? Image.network(
                                  ingredient.icon!,
                                  width: 24,
                                  height: 24,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.local_dining),
                                )
                              : const Icon(Icons.local_dining),
                          backgroundColor: Colors.grey[200],
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${basePrice.toStringAsFixed(0)}${widget.meal.currency}',
                    style:  TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColor.primaryTextColor,
                    ),
                  ),
                  if (addOnPrice > 0)
                    Text(
                      '${addOnPrice.toStringAsFixed(0)}${widget.meal.currency}',
                      style: TextStyle(
                        color: AppColor.subTextColor,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
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
                backgroundColor: AppColor.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text(
                'ADD TO CART',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}