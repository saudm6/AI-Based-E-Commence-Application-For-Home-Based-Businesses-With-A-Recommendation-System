import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'map_picker_page.dart';
import 'order/order_page_seller.dart';

class SettingsSeller extends StatefulWidget {
  const SettingsSeller({super.key});

  @override
  State<SettingsSeller> createState() => _SettingsSellerState();
}

class _SettingsSellerState extends State<SettingsSeller> {
  // Store status
  final List<String> _statuses = ['Closed', 'On-Holiday', 'Open', 'Busy'];
  int _selectedIndex = 0;
  bool _loading = true;
  String? _error;
  GeoPoint? _storeLocation;
  String? _companyImageUrl;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Get seller settings from firestore
  Future<void> _loadSettings() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final status = data['storeStatus'] as String?;
        if (status != null) {
          final idx = _statuses.indexOf(status);
          if (idx >= 0) _selectedIndex = idx;
        }
        if (data['storeLocation'] is GeoPoint) {
          _storeLocation = data['storeLocation'] as GeoPoint;
        }
        _companyImageUrl = data['companyImageUrl'] as String?;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _loading = false);
    }
  }

  // Change company logo
  Future<void> _changeCompanyImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseStorage.instance
        .ref()
        .child('company_images')
        .child('$uid.jpg');
    await ref.putFile(File(picked.path));
    final url = await ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'companyImageUrl': url});
    setState(() => _companyImageUrl = url);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Company image updated')));
  }

  // Change store status
  Future<void> _updateStatus(int idx) async {
    setState(() => _selectedIndex = idx);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'storeStatus': _statuses[idx]});
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Store status set to ${_statuses[idx]}')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Open location in google maps
  Future<void> _openInMaps() async {
    if (_storeLocation == null) return;
    final lat = _storeLocation!.latitude;
    final lng = _storeLocation!.longitude;
    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not open Maps')));
    }
  }

  @override
  Widget build(BuildContext context) {

    // Loading state
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Error state
    if (_error != null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: Center(child: Text('Error: $_error')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display company image
            if (_companyImageUrl != null)
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: NetworkImage(_companyImageUrl!),
                ),
              )
            else
              Center(
                child: CircleAvatar(
                  radius: 48,
                  child: Icon(Icons.store, size: 48),
                ),
              ),
            const SizedBox(height: 12),

            // Change image button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _changeCompanyImage,
                child: const Text('Change Company Image'),
              ),
            ),

            const SizedBox(height: 24),

            // Store status
            const Text('Store Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ToggleButtons(
              isSelected:
                  List.generate(_statuses.length, (i) => i == _selectedIndex),
              onPressed: _updateStatus,
              children: _statuses
                  .map((s) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(s)))
                  .toList(),
            ),

            const SizedBox(height: 24),

            // Store location
            const Text('Store Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      onPressed: () async {

                        // Chose location
                        final latLng = await Get.to<LatLng>(() => MapPickerPage(
                              initialLocation: _storeLocation != null
                                  ? LatLng(_storeLocation!.latitude,
                                      _storeLocation!.longitude)
                                  : null,
                            ));
                        if (latLng != null) {
                          final gp =
                              GeoPoint(latLng.latitude, latLng.longitude);
                          setState(() => _storeLocation = gp);

                          // Save new location
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .update({'storeLocation': gp});
                        }
                      },
                      child: const Text('Pick on Map')),
                ),

                const SizedBox(width: 8),

                ElevatedButton(
                        onPressed: _storeLocation == null ? null : _openInMaps,
                        child: const Text('Open in Maps')),

                const SizedBox(width: 8),


              ],
            ),
            const SizedBox(height: 12),
            const Text('Orders',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton(
                    onPressed: () => Get.to(() => const OrdersPageSeller()),
                    child: const Text('View Orders')),
            const Spacer(),

            // Logout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Get.offAllNamed('/sign-in');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
