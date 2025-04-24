import 'dart:convert';

import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/cart_item.dart';
import 'package:eshi_tap/features/Restuarant/presentation/address_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> cartItems = [];
  String deliveryAddress = 'address street 1'; // Default placeholder

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  // Load cart items from SharedPreferences
  Future<void> _loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartItemsJson = prefs.getStringList('cart_items') ?? [];
    setState(() {
      cartItems = cartItemsJson
          .map((json) => CartItem.fromJson(jsonDecode(json)))
          .toList();
    });
  }

  // Update cart item quantity
  Future<void> _updateCartItemQuantity(int index, int newQuantity) async {
    if (newQuantity < 1) return; // Prevent quantity from going below 1
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cartItems[index] = CartItem(
        meal: cartItems[index].meal,
        quantity: newQuantity,
        selectedAddOns: cartItems[index].selectedAddOns,
        addOnQuantities: cartItems[index].addOnQuantities,
      );
    });

    // Save updated cart to SharedPreferences
    final cartItemsJson =
        cartItems.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('cart_items', cartItemsJson);
  }

  // Remove item from cart
  Future<void> _removeCartItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cartItems.removeAt(index);
    });

    // Save updated cart to SharedPreferences
    final cartItemsJson =
        cartItems.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('cart_items', cartItemsJson);
  }

  double _calculateTotalPrice() {
    return cartItems.fold(0.0, (total, item) {
      double itemPrice = item.meal.price * item.quantity;
      for (int i = 0; i < item.selectedAddOns.length; i++) {
        itemPrice += item.selectedAddOns[i].price * item.addOnQuantities[i];
      }
      return total + itemPrice;
    });
  }

  Future<void> _createOrder(String address, String transactionId) async {
    try {
      const String orderApiUrl = 'YOUR_ORDER_API_URL';
      const String customerId = 'YOUR_CUSTOMER_ID';
      const String restaurantId = 'YOUR_RESTAURANT_ID';

      final items = cartItems.map((cartItem) {
        double totalPrice = cartItem.meal.price * cartItem.quantity;
        for (int i = 0; i < cartItem.selectedAddOns.length; i++) {
          totalPrice +=
              cartItem.selectedAddOns[i].price * cartItem.addOnQuantities[i];
        }
        return {
          'item': cartItem.meal.id,
          'quantity': cartItem.quantity,
          'price': totalPrice / cartItem.quantity,
        };
      }).toList();

      final response = await http.post(
        Uri.parse(orderApiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'restaurant': restaurantId,
          'customer': customerId,
          'items': items,
          'orderStatus': 'pending',
          'totalAmount': _calculateTotalPrice(),
          'deliveryAddress': address,
          'payment': {
            'method': 'chapa',
            'status': 'completed', // Should be verified by backend
            'transactionId': transactionId,
            'paymentDate': DateTime.now().toIso8601String(),
          },
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final orderId =
            data['_id'] ?? transactionId; // Fallback to transactionId
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('recent_order_id', orderId); // Save orderId
        await prefs.setStringList('cart_items', []);
        setState(() {
          cartItems.clear();
          deliveryAddress = address;
        });
        // Navigation to OrderConfirmationPage is handled by AddressSelectionPage
      } else {
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order error: $e')),
      );
    }
  }

  void _showOrderSummary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final totalPrice = _calculateTotalPrice();
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: AppColor.primaryColor,
                    title: const Text(
                      'Cart',
                      style: TextStyle(color: Colors.white),
                    ),
                    leading: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close bottom sheet to edit
                        },
                        child: const Text(
                          'EDIT ITEMS',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    elevation: 0,
                  ),
                  Expanded(
                    child: cartItems.isEmpty
                        ? const Center(
                            child: Text(
                              'Your cart is empty',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16.0),
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final cartItem = cartItems[index];
                              String imageUrl =
                                  'https://via.placeholder.com/150';
                              if (cartItem.meal.images.isNotEmpty) {
                                final defaultImage =
                                    cartItem.meal.images.firstWhere(
                                  (image) => image.defaultImage,
                                  orElse: () => cartItem.meal.images.first,
                                );
                                imageUrl = defaultImage.secureUrl;
                              }

                              double itemPrice =
                                  cartItem.meal.price * cartItem.quantity;
                              for (int i = 0;
                                  i < cartItem.selectedAddOns.length;
                                  i++) {
                                itemPrice += cartItem.selectedAddOns[i].price *
                                    cartItem.addOnQuantities[i];
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        imageUrl,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.error,
                                                    color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cartItem.meal.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${itemPrice.toStringAsFixed(0)}birr',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${cartItem.quantity}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'DELIVERY ADDRESS',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddressSelectionPage(
                                      cartItems: cartItems.map((item) => item.toJson()).toList(),
                                      totalAmount: totalPrice,
                                      onPlaceOrder:
                                          (address, transactionId) async {
                                        await _createOrder(
                                            address, transactionId);
                                      }, restaurantId: '',
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'EDIT',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            deliveryAddress,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'TOTAL: ${totalPrice.toStringAsFixed(0)}birr',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddressSelectionPage(
                                    totalAmount: totalPrice,
                                    cartItems: cartItems.map((item) {
                                      double itemPrice =
                                          item.meal.price * item.quantity;
                                      for (int i = 0;
                                          i < item.selectedAddOns.length;
                                          i++) {
                                        itemPrice +=
                                            item.selectedAddOns[i].price *
                                                item.addOnQuantities[i];
                                      }
                                      return {
                                        'item': item.meal.id,
                                        'quantity': item.quantity,
                                        'price': itemPrice / item.quantity,
                                      };
                                    }).toList(),
                                    onPlaceOrder:
                                        (address, transactionId) async {
                                      await _createOrder(
                                          address, transactionId);
                                    }, restaurantId: '',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'PLACE ORDER',
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
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        title: const Text(
          'Cart',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppColor.primaryColor,
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final cartItem = cartItems[index];
                String imageUrl = 'https://via.placeholder.com/150';
                if (cartItem.meal.images.isNotEmpty) {
                  final defaultImage = cartItem.meal.images.firstWhere(
                    (image) => image.defaultImage,
                    orElse: () => cartItem.meal.images.first,
                  );
                  imageUrl = defaultImage.secureUrl;
                }

                double itemPrice = cartItem.meal.price * cartItem.quantity;
                for (int i = 0; i < cartItem.selectedAddOns.length; i++) {
                  itemPrice += cartItem.selectedAddOns[i].price *
                      cartItem.addOnQuantities[i];
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cartItem.meal.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${itemPrice.toStringAsFixed(0)}birr',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.redAccent),
                                  onPressed: () {
                                    _updateCartItemQuantity(
                                        index, cartItem.quantity - 1);
                                  },
                                ),
                                Text(
                                  '${cartItem.quantity}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle,
                                      color: Colors.green),
                                  onPressed: () {
                                    _updateCartItemQuantity(
                                        index, cartItem.quantity + 1);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.redAccent),
                        onPressed: () => _removeCartItem(index),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _showOrderSummary,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'DONE',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
