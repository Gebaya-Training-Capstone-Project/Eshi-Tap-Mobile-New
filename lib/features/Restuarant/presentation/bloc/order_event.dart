part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

class CreateOrderEvent extends OrderEvent {
  final String restaurantId;
  final String customerId;
  final List<Map<String, dynamic>> items;
  final String orderStatus;
  final double totalAmount;
  final double latitude;
  final double longitude;

  const CreateOrderEvent({
    required this.restaurantId,
    required this.customerId,
    required this.items,
    required this.orderStatus,
    required this.totalAmount,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [
        restaurantId,
        customerId,
        items,
        orderStatus,
        totalAmount,
        latitude,
        longitude,
      ];
}

class FetchOrderEvent extends OrderEvent {
  final String orderId;

  const FetchOrderEvent(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class StartOrderUpdates extends OrderEvent {
  final String orderId;

  const StartOrderUpdates(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class StopOrderUpdates extends OrderEvent {}