part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class CreateOrderEvent extends OrderEvent {
  final String restaurantId;
  final String customerId;
  final List<Map<String, dynamic>> items;
  final String orderStatus;
  final double totalAmount;
  final String deliveryAddress;
  final String phoneNumber;
  final String txRef;

  const CreateOrderEvent({
    required this.restaurantId,
    required this.customerId,
    required this.items,
    required this.orderStatus,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.phoneNumber,
    required this.txRef,
  });

  @override
  List<Object?> get props => [
        restaurantId,
        customerId,
        items,
        orderStatus,
        totalAmount,
        deliveryAddress,
        phoneNumber,
        txRef,
      ];
}

class FetchOrderEvent extends OrderEvent {
  final String orderId;

  const FetchOrderEvent(this.orderId);

  @override
  List<Object> get props => [orderId];
}