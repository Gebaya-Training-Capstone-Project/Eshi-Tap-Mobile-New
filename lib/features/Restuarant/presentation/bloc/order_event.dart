import 'package:equatable/equatable.dart';

sealed class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

class PlaceOrder extends OrderEvent {
  final String address;
  final double totalAmount;
  final List<Map<String, dynamic>> cartItems;

  const PlaceOrder({
    required this.address,
    required this.totalAmount,
    required this.cartItems,
  });

  @override
  List<Object> get props => [address, totalAmount, cartItems];
}

class PaymentSuccessful extends OrderEvent {}