import 'dart:convert';
import 'package:chapasdk/chapasdk.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/order_bloc.dart';
import 'package:eshi_tap/features/Restuarant/presentation/order_confirmation_page.dart';
import 'package:eshi_tap/features/Restuarant/presentation/order_tracker_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressSelectionPage extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> cartItems;
  final String restaurantId;
  final Function(String, String) onPlaceOrder;

  const AddressSelectionPage({
    super.key,
    required this.totalAmount,
    required this.cartItems,
    required this.restaurantId,
    required this.onPlaceOrder,
  });

  @override
  State<AddressSelectionPage> createState() => _AddressSelectionPageState();
}

class _AddressSelectionPageState extends State<AddressSelectionPage> {
  List<String> savedAddresses = [];
  List<String> recentAddresses = [];
  String? selectedAddress;
  String? _phoneNumber;
  final TextEditingController _addressController = TextEditingController();
  LatLng _selectedLocation = const LatLng(9.03, 38.74); // Default: Addis Ababa
  final MapController _mapController = MapController();
  bool _isLoading = false;
  String? _txRef;

  final String chapaPublicKey = 'CHAPUBK_TEST-djffhCEw498HcZcG1oknfi1WMGvQtQlU';

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedAddresses = prefs.getStringList('saved_addresses') ?? [];
      recentAddresses = prefs.getStringList('recent_addresses') ?? [];
    });
  }

  Future<String> _getCustomerId() async {
    return '67f3ddb5d84269b6463c0ede';
  }

  Future<void> _storeOrderDetails(String txRef, {String? chapaTxRef}) async {
    final customerId = await _getCustomerId();
    final prefs = await SharedPreferences.getInstance();
    final orderDetails = {
      'restaurantId': widget.restaurantId,
      'customerId': customerId,
      'cartItems': widget.cartItems,
      'totalAmount': widget.totalAmount,
      'orderStatus': 'preparing', // Changed to "preparing" to match API requirements
      'txRef': txRef,
      'chapaTxRef': chapaTxRef,
      'deliveryAddress': selectedAddress,
      'phoneNumber': _phoneNumber,
      'latitude': _selectedLocation.longitude,
      'longtiude': _selectedLocation.latitude,
    };
    await prefs.setString('pending_order', jsonEncode(orderDetails));
  }

  Future<void> _addNewAddress(String address) async {
    if (address.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (!recentAddresses.contains(address)) {
        recentAddresses.insert(0, address);
        if (recentAddresses.length > 5) recentAddresses.removeLast();
        prefs.setStringList('recent_addresses', recentAddresses);
      }
      selectedAddress = address;
      _addressController.text = address;
    });
  }

  Future<void> _saveAddress(String address) async {
    if (address.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (!savedAddresses.contains(address)) {
        savedAddresses.add(address);
        prefs.setStringList('saved_addresses', savedAddresses);
      }
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isValidPhoneNumber(String phone) {
    final regex = RegExp(r'^(09|07)[0-9]{8}$|^(\+2519|\+2517)[0-9]{8}$');
    return regex.hasMatch(phone);
  }

  Future<void> _initiatePayment() async {
    if (kIsWeb) {
      _showSnackbar('Payment not supported on web. Please use mobile app.');
      return;
    }
    if (_phoneNumber == null || !_isValidPhoneNumber(_phoneNumber!)) {
      _showSnackbar('Please enter a valid phone number (e.g., 0911112233)');
      return;
    }
    if (selectedAddress == null) {
      _showSnackbar('Please select a delivery address');
      return;
    }

    bool isConnected = await DataConnectionChecker().hasConnection;
    if (!isConnected) {
      _showSnackbar('No internet connection');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final customerId = await _getCustomerId();
      final txRef = 'eshi-tap-tx-$customerId-${DateTime.now().millisecondsSinceEpoch}';
      setState(() => _txRef = txRef);
      await _storeOrderDetails(txRef);

      await Chapa.paymentParameters(
        context: context,
        publicKey: chapaPublicKey,
        currency: 'ETB',
        amount: widget.totalAmount.toStringAsFixed(2),
        email: 'customer@example.com',
        phone: _phoneNumber!.startsWith('+251') ? _phoneNumber!.substring(4) : _phoneNumber!,
        firstName: 'Customer',
        lastName: 'Name',
        txRef: txRef,
        title: 'Food Order Payment',
        desc: 'Payment for your food order',
        nativeCheckout: true,
        namedRouteFallBack: '/order_confirmation',
        showPaymentMethodsOnGridView: true,
        availablePaymentMethods: ['telebirr', 'cbebirr'],
      );
    } catch (e) {
      debugPrint('Payment error: $e');
      setState(() => _isLoading = false);
      _showSnackbar('Payment Error: $e');
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Delivery Address', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: _selectedLocation,
                  zoom: 13.0,
                  onTap: (tapPosition, point) {
                    setState(() {
                      _selectedLocation = point;
                      selectedAddress = 'Location: (${point.latitude}, ${point.longitude})';
                      _addressController.text = selectedAddress!;
                    });
                    _mapController.move(point, 13.0);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLocation,
                        builder: (ctx) => const Icon(Icons.location_pin, color: Colors.green, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '0911223344',
                      prefixIcon: const Icon(Icons.phone, color: Colors.green),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => _phoneNumber = value,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Delivery Address',
                      hintText: 'Tap on map to select',
                      prefixIcon: const Icon(Icons.location_on, color: Colors.green),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.my_location, color: Colors.green),
                        onPressed: () => _showSnackbar('Fetching current location...'),
                      ),
                    ),
                    onSubmitted: _addNewAddress,
                  ),
                  const SizedBox(height: 20),
                  if (savedAddresses.isNotEmpty) ...[
                    const Text('Saved Addresses', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    ...savedAddresses.map((address) => _buildAddressItem(address, icon: Icons.bookmark, onTap: () {
                          setState(() {
                            selectedAddress = address;
                            _addressController.text = address;
                          });
                        })),
                    const SizedBox(height: 20),
                  ],
                  if (recentAddresses.isNotEmpty) ...[
                    const Text('Recent Addresses', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    ...recentAddresses.map((address) => _buildAddressItem(address, icon: Icons.history, onTap: () {
                          setState(() {
                            selectedAddress = address;
                            _addressController.text = address;
                          });
                        }, onSave: () => _saveAddress(address))),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 18, color: Colors.black87)),
                      Text('${widget.totalAmount.toStringAsFixed(2)} ETB', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _initiatePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                          : const Text('Proceed to Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressItem(String address, {required IconData icon, required VoidCallback onTap, VoidCallback? onSave}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(address, style: const TextStyle(fontSize: 16)),
        trailing: onSave != null ? IconButton(icon: const Icon(Icons.bookmark_border, color: Colors.green), onPressed: onSave) : null,
        onTap: onTap,
      ),
    );
  }
}