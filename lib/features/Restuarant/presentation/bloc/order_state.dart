part of 'order_bloc.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderCreated extends OrderState {
  final String orderId;

  const OrderCreated({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

class OrderLoaded extends OrderState {
  final Map<String, dynamic> order;

  const OrderLoaded({required this.order});

  @override
  List<Object> get props => [order];
}

class OrderError extends OrderState {
  final String message;

  const OrderError({required this.message});

  @override
  List<Object> get props => [message];
}