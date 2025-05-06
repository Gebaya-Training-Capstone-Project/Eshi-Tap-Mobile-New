import 'package:eshi_tap/features/Restuarant/domain/entity/order.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/restaurant.dart';

class OrderModel extends Order {
  OrderModel({
    required String id,
    required Restaurant restaurant,
    String? driverId,
    required String customerId,
    required List<OrderItemModel> items,
    required String orderStatus,
    required double totalAmount,
    required bool isRated,
    required String createdAt,
    required String updatedAt,
    String? deliveryAddress,
    Driver? driver,
  }) : super(
          id: id,
          restaurant: restaurant,
          driverId: driverId,
          customerId: customerId,
          items: items,
          orderStatus: orderStatus,
          totalAmount: totalAmount,
          isRated: isRated,
          createdAt: createdAt,
          updatedAt: updatedAt,
          deliveryAddress: deliveryAddress,
          driver: driver,
        );

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] as String,
      restaurant: Restaurant.fromJson(json['restaurant'] as Map<String, dynamic>),
      driverId: json['driver'] as String?,
      customerId: json['customer'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      orderStatus: json['orderStatus'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      isRated: json['isRated'] as bool,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      deliveryAddress: json['deliveryAddress'] as String?,
      driver: json['driver'] != null
          ? Driver.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'restaurant': (restaurant as Restaurant).toJson(),
      'driver': driverId,
      'customer': customerId,
      'items': items.map((item) => (item as OrderItemModel).toJson()).toList(),
      'orderStatus': orderStatus,
      'totalAmount': totalAmount,
      'isRated': isRated,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deliveryAddress': deliveryAddress,
      'driver': driver?.toJson(),
    };
  }
}

class OrderItemModel extends OrderItem {
  OrderItemModel({
    String? itemId,
    required int quantity,
    required double price,
    required String id,
  }) : super(
          itemId: itemId,
          quantity: quantity,
          price: price,
          id: id,
        );

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      itemId: json['item'] as String?,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      id: json['_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': itemId,
      'quantity': quantity,
      'price': price,
      '_id': id,
    };
  }
}