import 'package:equatable/equatable.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/restaurant.dart';

class Order extends Equatable {
  final String id;
  final Restaurant restaurant;
  final String? driverId;
  final String customerId;
  final List<OrderItem> items;
  final String orderStatus;
  final double totalAmount;
  final bool isRated;
  final String createdAt;
  final String updatedAt;
  final String? deliveryAddress;
  final Driver? driver;

  const Order({
    required this.id,
    required this.restaurant,
    this.driverId,
    required this.customerId,
    required this.items,
    required this.orderStatus,
    required this.totalAmount,
    required this.isRated,
    required this.createdAt,
    required this.updatedAt,
    this.deliveryAddress,
    this.driver,
  });

  @override
  List<Object?> get props => [
        id,
        restaurant,
        driverId,
        customerId,
        items,
        orderStatus,
        totalAmount,
        isRated,
        createdAt,
        updatedAt,
        deliveryAddress,
        driver,
      ];
}

class OrderItem extends Equatable {
  final String? itemId;
  final int quantity;
  final double price;
  final String id;

  const OrderItem({
    this.itemId,
    required this.quantity,
    required this.price,
    required this.id,
  });

  @override
  List<Object?> get props => [itemId, quantity, price, id];
}

class Driver extends Equatable {
  final String id;
  final String username;
  final String? phone;

  const Driver({
    required this.id,
    required this.username,
    this.phone,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['_id'] as String,
      username: json['username'] as String,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'phone': phone,
    };
  }

  @override
  List<Object?> get props => [id, username, phone];
}