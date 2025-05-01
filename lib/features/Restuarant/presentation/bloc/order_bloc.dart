import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/order.dart';
import 'package:eshi_tap/features/Restuarant/domain/usecase/create_order.dart';
import 'package:eshi_tap/features/Restuarant/domain/usecase/get_order_by_id.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final CreateOrder createOrder;
  final GetOrderById getOrderById;

  OrderBloc(this.createOrder, this.getOrderById) : super(OrderInitial()) {
    on<CreateOrderEvent>(_onCreateOrder);
    on<FetchOrderEvent>(_onFetchOrder);
  }

  Future<void> _onCreateOrder(CreateOrderEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    final result = await createOrder(
      restaurantId: event.restaurantId,
      customerId: event.customerId,
      items: event.items,
      orderStatus: event.orderStatus,
      totalAmount: event.totalAmount,
      deliveryAddress: event.deliveryAddress,
      phoneNumber: event.phoneNumber,
      txRef: event.txRef,
    );
    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (order) => emit(OrderCreated(order)),
    );
  }

  Future<void> _onFetchOrder(FetchOrderEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    final result = await getOrderById(event.orderId);
    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (order) => emit(OrderLoaded(order)),
    );
  }
}