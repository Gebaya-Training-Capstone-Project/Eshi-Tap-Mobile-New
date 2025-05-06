import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final Dio dio;
  Timer? _pollingTimer;
  StreamController<Map<String, dynamic>>? _orderUpdatesController;

  OrderBloc({required this.dio}) : super(OrderInitial()) {
    on<CreateOrderEvent>(_onCreateOrder);
    on<FetchOrderEvent>(_onFetchOrder);
    on<StartOrderUpdates>(_onStartOrderUpdates);
    on<StopOrderUpdates>(_onStopOrderUpdates);
  }

  Future<void> _onCreateOrder(
      CreateOrderEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3ZjNkZGI1ZDg0MjY5YjY0NjNjMGVkZSIsInJvbGUiOiJjdXN0b21lciIsImVtYWlsIjoibmViaW1vYmlsZUBnbWFpbC5jb20iLCJpYXQiOjE3NDYxMTk2MDAsImV4cCI6MTc0ODcxMTYwMH0.POQyG_yEWzRYzTnru_5FELM7reHdqBqCyxNNpFZwC6A';
      
      final response = await dio.post(
        'https://eshi-tap.vercel.app/api/order',
        data: {
          "restaurant": event.restaurantId,
          "customer": event.customerId,
          "items": event.items,
          "orderStatus": event.orderStatus,
          "totalAmount": event.totalAmount,
          "latitude": event.latitude,
          "longtiude": event.longitude,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final orderId = response.data['data'][0]['_id'];
        debugPrint('Order successfully created with ID: $orderId');
        emit(OrderCreated(orderId: orderId));
        add(FetchOrderEvent(orderId));
      } else {
        debugPrint('Failed to create order: ${response.data['message']}');
        emit(OrderError(message: response.data['message'] ?? 'Failed to create order'));
      }
    } catch (e) {
      debugPrint('Error creating order: $e');
      emit(OrderError(message: e.toString()));
    }
  }

  Future<void> _onFetchOrder(
      FetchOrderEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3ZjNkZGI1ZDg0MjY5YjY0NjNjMGVkZSIsInJvbGUiOiJjdXN0b21lciIsImVtYWlsIjoibmViaW1vYmlsZUBnbWFpbC5jb20iLCJpYXQiOjE3NDYxMTk2MDAsImV4cCI6MTc0ODcxMTYwMH0.POQyG_yEWzRYzTnru_5FELM7reHdqBqCyxNNpFZwC6A';
      
      final response = await dio.get(
        'https://eshi-tap.vercel.app/api/order/${event.orderId}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final orderData = response.data['data'];
        emit(OrderLoaded(order: orderData));
      } else {
        emit(OrderError(message: response.data['message'] ?? 'Failed to fetch order'));
      }
    } catch (e) {
      emit(OrderError(message: e.toString()));
    }
  }

  void _onStartOrderUpdates(
      StartOrderUpdates event, Emitter<OrderState> emit) {
    _orderUpdatesController = StreamController<Map<String, dynamic>>.broadcast();
    
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3ZjNkZGI1ZDg0MjY5YjY0NjNjMGVkZSIsInJvbGUiOiJjdXN0b21lciIsImVtYWlsIjoibmViaW1vYmlsZUBnbWFpbC5jb20iLCJpYXQiOjE3NDYxMTk2MDAsImV4cCI6MTc0ODcxMTYwMH0.POQyG_yEWzRYzTnru_5FELM7reHdqBqCyxNNpFZwC6A';
        final response = await dio.get(
          'https://eshi-tap.vercel.app/api/order/${event.orderId}',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );

        if (response.statusCode == 200) {
          final orderData = response.data['data'];
          _orderUpdatesController?.add(orderData);
          if (orderData['driver'] != null) {
            add(StopOrderUpdates());
          }
        }
      } catch (e) {
        debugPrint('Error polling order updates: $e');
      }
    });
  }

  void _onStopOrderUpdates(StopOrderUpdates event, Emitter<OrderState> emit) {
    _pollingTimer?.cancel();
    _orderUpdatesController?.close();
    _orderUpdatesController = null;
  }

  Stream<Map<String, dynamic>> get orderUpdates {
    return _orderUpdatesController?.stream ?? const Stream.empty();
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    _orderUpdatesController?.close();
    return super.close();
  }
}