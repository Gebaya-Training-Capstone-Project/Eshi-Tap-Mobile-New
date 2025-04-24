import 'package:equatable/equatable.dart';

enum PaymentStatus { initial, loading, loaded, success, error }

class OrderState extends Equatable {
  final PaymentStatus paymentStatus;
  final String errorMessage;
  final String paymentUrl;
  final String transactionId;

  const OrderState({
    required this.paymentStatus,
    required this.errorMessage,
    required this.paymentUrl,
    required this.transactionId,
  });

  factory OrderState.initial() {
    return const OrderState(
      paymentStatus: PaymentStatus.initial,
      errorMessage: '',
      paymentUrl: '',
      transactionId: '',
    );
  }

  @override
  List<Object> get props => [paymentStatus, errorMessage, paymentUrl, transactionId];

  OrderState copyWith({
    PaymentStatus? paymentStatus,
    String? errorMessage,
    String? paymentUrl,
    String? transactionId,
  }) {
    return OrderState(
      paymentStatus: paymentStatus ?? this.paymentStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      transactionId: transactionId ?? this.transactionId,
    );
  }
}