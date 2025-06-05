import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DetailedUserInfoScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const DetailedUserInfoScreen({
    super.key,
    required this.userId,
    required this.userData,
  });

  @override
  State<DetailedUserInfoScreen> createState() => _DetailedUserInfoScreenState();
}

class _DetailedUserInfoScreenState extends State<DetailedUserInfoScreen> {
  bool _isDeleting = false;

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Not available';
    return DateFormat.yMMMMd().add_jm().format(timestamp.toDate());
  }

  Widget _buildDetailRow(BuildContext context, String label, dynamic value) {
    String displayValue;
    Widget valueWidget;

    if (value == null || (value is String && value.isEmpty)) {
      displayValue = 'Not provided';
      valueWidget = Text(displayValue, style: const TextStyle(fontSize: 16));
    } else if (value is Timestamp) {
      displayValue = _formatTimestamp(value);
      valueWidget = Text(displayValue, style: const TextStyle(fontSize: 16));
    } else if (value is num) {
      displayValue = value.toString();
      valueWidget = Text(displayValue, style: const TextStyle(fontSize: 16));
    } else {
      displayValue = value.toString();
      bool isUrl = displayValue.startsWith('http://') || displayValue.startsWith('https://');
      valueWidget = Text(
        displayValue,
        style: TextStyle(
          fontSize: 16,
          color: isUrl ? Theme.of(context).colorScheme.primary : null,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: valueWidget),
        ],
      ),
    );
  }

  Future<void> _deleteUserAndAssociatedData() async {
    if (_isDeleting) return;
    setState(() {
      _isDeleting = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final userRole = widget.userData['role'] as String?;

      WriteBatch? batch;

      if (userRole == 'seller') {
        batch = firestore.batch();
        final productsQuery = await firestore
            .collection('products')
            .where('sellerId', isEqualTo: widget.userId)
            .get();

        if (productsQuery.docs.isNotEmpty) {
          for (final productDoc in productsQuery.docs) {
            batch.delete(productDoc.reference);
          }
        }
      }

      // Delete user doc
      final userDocRef = firestore.collection('users').doc(widget.userId);
      if (batch != null) {
        batch.delete(userDocRef);
        await batch.commit();
      } else {
        await userDocRef.delete();
      }


      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${userRole == 'seller' ? 'Seller' : 'User'} deleted successfully.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  // Delete confirmation
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete ${widget.userData['role'] ?? 'user'}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(ctx).pop();
                _deleteUserAndAssociatedData();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final String storeName = widget.userData['storeName'] as String? ?? 'User Details';
    final String? email = widget.userData['email'] as String?;
    final num? phoneNumber = widget.userData['phoneNumber'] as num?;
    final String? role = widget.userData['role'] as String?;
    final String? companyId = widget.userData['companyId'] as String?;
    final dynamic rawBusinessCategory = widget.userData['businessCategory'];
    String? businessCategoryDisplayValue;
    if (rawBusinessCategory is Map && rawBusinessCategory.containsKey('name')) {
      businessCategoryDisplayValue = rawBusinessCategory['name'] as String?;
    } else if (rawBusinessCategory is String) {
      businessCategoryDisplayValue = rawBusinessCategory;
    }
    final String? certificateUrl = widget.userData['certificateUrl'] as String?;
    final Timestamp? createdAt = widget.userData['createdAt'] as Timestamp?;

    return Scaffold(
      appBar: AppBar(
        title: Text(storeName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),

        // Show user details + delete button
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildDetailRow(context, 'User/Doc ID', widget.userId),
            _buildDetailRow(context, 'Company (Link) ID', companyId),
            _buildDetailRow(context, 'Store Name', storeName),
            _buildDetailRow(context, 'Email', email),
            _buildDetailRow(context, 'Phone Number', phoneNumber),
            _buildDetailRow(context, 'Role', role),
            _buildDetailRow(context, 'Business Category', businessCategoryDisplayValue),
            _buildDetailRow(context, 'Certificate URL', certificateUrl),
            _buildDetailRow(context, 'Created At', createdAt),
            const SizedBox(height: 20),
            Center(
              child: _isDeleting
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                icon: const Icon(Icons.delete_forever),
                label: Text('Delete ${role ?? 'User'}'),
                onPressed: _confirmDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}