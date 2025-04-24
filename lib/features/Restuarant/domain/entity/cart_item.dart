import 'dart:convert';

import 'package:eshi_tap/features/Restuarant/domain/entity/meal.dart';

class CartItem {
  final Meal meal;
  final int quantity;
  final List<AddOn> selectedAddOns;
  final List<int> addOnQuantities;

  CartItem({
    required this.meal,
    required this.quantity,
    required this.selectedAddOns,
    required this.addOnQuantities,
  });

  Map<String, dynamic> toJson() {
    return {
      'meal': meal.toJson(),
      'quantity': quantity,
      'selectedAddOns': selectedAddOns.map((addon) => addon.toJson()).toList(),
      'addOnQuantities': addOnQuantities,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      meal: Meal.fromJson(json['meal']),
      quantity: json['quantity'],
      selectedAddOns: (json['selectedAddOns'] as List)
          .map((addonJson) => AddOn.fromJson(addonJson))
          .toList(),
      addOnQuantities: List<int>.from(json['addOnQuantities']),
    );
  }
}