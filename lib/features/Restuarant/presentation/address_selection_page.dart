import 'package:chapasdk/chapasdk.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Restuarant/presentation/order_tracker_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
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
  LatLng _selectedLocation = LatLng(9.03, 38.74); // Default: Addis Ababa
  final MapController _mapController = MapController();
  bool _isLoading = false;

  // Hardcode the Chapa public key
  final String chapaPublicKey = 'CHAPUBK_TEST-djffhCEw498HcZcG1oknfi1WMGvQtQlU';

  @override
  void initState() {
    super.initState();
    debugPrint('AddressSelectionPage initialized with totalAmount: ${widget.totalAmount}');
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
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('customer_id') ?? 'default_customer_id';
  }

  Future<void> _addNewAddress(String address) async {
    if (address.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (!recentAddresses.contains(address)) {
        recentAddresses.insert(0, address);
        if (recentAddresses.length > 5) {
          recentAddresses.removeLast();
        }
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _isValidPhoneNumber(String phone) {
    final regex = RegExp(r'^(09|07)[0-9]{8}$|^(\+2519|\+2517)[0-9]{8}$');
    return regex.hasMatch(phone);
  }

  Future<void> _initiatePayment() async {
    debugPrint('Initiating payment with phone: $_phoneNumber, address: $selectedAddress');
    if (kIsWeb) {
      _showSnackbar('Payment not supported on web. Please use mobile app.');
      setState(() {
        _isLoading = false;
      });
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
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final customerId = await _getCustomerId();
      final txRef = 'eshi-tap-tx-${customerId}-${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('Chapa txRef: $txRef, publicKey: $chapaPublicKey');

      await Chapa.paymentParameters(
        context: context,
        publicKey: chapaPublicKey,
        currency: 'ETB',
        amount: widget.totalAmount.toStringAsFixed(2),
        email: 'customer@example.com',
        phone: _phoneNumber!.startsWith('+251') ? _phoneNumber!.substring(4) : _phoneNumber!,
        firstName: 'John',
        lastName: 'Doe',
        txRef: txRef,
        title: 'Order Payment',
        desc: 'Payment for your food order',
        nativeCheckout: true,
        namedRouteFallBack: '/order_tracker?tx_ref=$txRef',
        showPaymentMethodsOnGridView: true,
        availablePaymentMethods: ['telebirr', 'cbebirr'],
      );

      // Payment result is handled via namedRouteFallBack
    } catch (e) {
      debugPrint('Payment error: $e');
      setState(() {
        _isLoading = false;
      });
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
        backgroundColor: AppColor.primaryColor,
        title: const Text(
          'Select Delivery Address',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _selectedLocation,
                zoom: 13.0,
                onTap: (tapPosition, point) async {
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
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation,
                      width: 40,
                      height: 40,
                      builder: (context) => const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter phone number (e.g., 0911112233)',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => _phoneNumber = value,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: 'Enter delivery address',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onSubmitted: _addNewAddress,
                  ),
                  const SizedBox(height: 16),
                  if (savedAddresses.isNotEmpty) ...[
                    const Text(
                      'Saved address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...savedAddresses.map((address) {
                      return ListTile(
                        leading: const Icon(Icons.star, color: Colors.yellow),
                        title: Text(address),
                        tileColor: selectedAddress == address ? Colors.grey[200] : null,
                        onTap: () {
                          setState(() {
                            selectedAddress = address;
                            _addressController.text = address;
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                  if (recentAddresses.isNotEmpty) ...[
                    const Text(
                      'Recent address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...recentAddresses.map((address) {
                      return ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(address),
                        trailing: IconButton(
                          icon: const Icon(Icons.bookmark_border),
                          onPressed: () => _saveAddress(address),
                        ),
                        tileColor: selectedAddress == address ? Colors.grey[200] : null,
                        onTap: () {
                          setState(() {
                            selectedAddress = address;
                            _addressController.text = address;
                          });
                        },
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL: ${widget.totalAmount.toStringAsFixed(0)} ETB',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedAddress != null && _phoneNumber != null && !_isLoading
                        ? _initiatePayment
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'PLACE ORDER',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}