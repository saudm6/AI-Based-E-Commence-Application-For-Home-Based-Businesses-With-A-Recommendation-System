import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../../common/widgets/form/product_category_selection_page.dart';
import '../../../controllers/product_category_controller.dart';
import '../../../models/product_category_model.dart';

// Color variant
class ColorVariant {
  final String color;
  final int quantity;
  ColorVariant({required this.color, required this.quantity});

  Map<String, dynamic> toJson() => {
    'color': color,
    'quantity': quantity,
  };

  factory ColorVariant.fromJson(Map<String, dynamic> json) => ColorVariant(
    color: json['color'] as String? ?? '',
    quantity: (json['quantity'] as num?)?.toInt() ?? 0,
  );
}

// Add product
class AddProductPage extends StatefulWidget {
  final String? productId;
  const AddProductPage({Key? key, this.productId}) : super(key: key);

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameC     = TextEditingController();
  final _descC     = TextEditingController();
  final _deliveryC = TextEditingController();
  final _priceC    = TextEditingController();

  final _picker     = ImagePicker();
  final RxList<XFile> _pickedImages = <XFile>[].obs;
  List<String> _existingImageUrls   = [];

  final _catCtrl = Get.put(ProductCategoryController());

  final List<ColorVariant> _variants = [];
  final List<String> _tags           = [];
  final _uuid = const Uuid();

  bool   _loading = true;
  String? _error;
  String? _companyId, _email, _storeName;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Seller profile
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw 'Not signed in';
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!userDoc.exists) throw 'Profile not found';

      final udata = userDoc.data()!;
      _companyId  = udata['companyId'] ?? uid;
      _email      = udata['email']     as String?;
      _storeName  = udata['storeName'] as String?;

      // Editing existing product
      if (widget.productId != null) {
        final doc = await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          _nameC.text      = data['productName']        ?? '';
          _descC.text      = data['productDescription'] ?? '';
          _deliveryC.text  = (data['deliveryTime']      ?? '').toString();

          final price = data['price'] as num?;
          if (price != null) _priceC.text = price.toString();

          // Selected category
          final cid   = data['categoryId']   as String?;
          final cname = data['categoryName'] as String?;
          if (cid != null && cname != null) {
            _catCtrl.selected.value = ProductCategoryModel(id: cid, name: cname);
          }

          // Tags
          final rawTags = data['tags'] as List<dynamic>?;
          if (rawTags != null) _tags.addAll(rawTags.cast<String>());

          // images
          _existingImageUrls = List<String>.from(data['productImages'] ?? []);

          // Colour variants
          final rawVars = data['colorVariants'] as List<dynamic>?;
          if (rawVars != null) {
            for (var v in rawVars) {
              if (v is Map<String, dynamic>) _variants.add(ColorVariant.fromJson(v));
            }
          }
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showAddTagDialog() {
    final tagC = TextEditingController();
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add a Tag'),
        content: TextField(controller: tagC, decoration: const InputDecoration(labelText: 'Tag')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),  child: const Text('Add')),
        ],
      ),
    ).then((add) {
      if (add == true) {
        final tag = tagC.text.trim();
        if (tag.isNotEmpty && !_tags.contains(tag)) {
          setState(() => _tags.add(tag));
        }
      }
    });
  }

  // Images
  Future<void> _pickImages() async {
    final imgs = await _picker.pickMultiImage(imageQuality: 85);
    if (imgs != null) _pickedImages.assignAll(imgs);
  }

  // Upload images
  Future<List<String>> _uploadNewImages() async {
    final storage = FirebaseStorage.instance;
    final List<String> urls = [];
    for (final img in _pickedImages) {
      final ref = storage
          .ref()
          .child('companies/$_companyId/products/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(File(img.path));
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }

  // Add color variant
  void _showAddVariantDialog() {
    final colorC = TextEditingController();
    final qtyC   = TextEditingController();
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Color Variant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: colorC, decoration: const InputDecoration(labelText: 'Color')),
            TextField(
              controller: qtyC,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),  child: const Text('Add')),
        ],
      ),
    ).then((add) {
      if (add == true) {
        final col = colorC.text.trim();
        final q   = int.tryParse(qtyC.text.trim()) ?? 0;
        setState(() => _variants.add(ColorVariant(color: col, quantity: q)));
      }
    });
  }

  // Edit current variant
  void _showEditVariantDialog(ColorVariant variant) {
    final colorC = TextEditingController(text: variant.color);
    final qtyC   = TextEditingController(text: variant.quantity.toString());
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Color Variant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: colorC, decoration: const InputDecoration(labelText: 'Color')),
            TextField(
              controller: qtyC,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),  child: const Text('Save')),
        ],
      ),
    ).then((save) {
      if (save == true) {
        final newColor = colorC.text.trim();
        final newQty   = int.tryParse(qtyC.text.trim()) ?? 0;
        setState(() {
          final idx = _variants.indexOf(variant);
          _variants[idx] = ColorVariant(color: newColor, quantity: newQty);
        });
      }
    });
  }

  // Submit data
  Future<void> _submit() async {
    if (_catCtrl.selected.value == null) {
      Get.snackbar('Missing info', 'Select a category first');
      return;
    }

    try {
      final id      = widget.productId ?? _uuid.v4();
      final newImgs = await _uploadNewImages();
      final allImgs = [..._existingImageUrls, ...newImgs];
      final price   = double.tryParse(_priceC.text.trim()) ?? 0;

      final data = {
        'productId'         : id,
        'productName'       : _nameC.text.trim(),
        'productDescription': _descC.text.trim(),
        'productImages'     : allImgs,
        'deliveryTime'      : int.tryParse(_deliveryC.text) ?? 0,
        'price'             : price,
        'categoryId'        : _catCtrl.selected.value!.id,
        'categoryName'      : _catCtrl.selected.value!.name,
        'product_Category'  : _catCtrl.selected.value!.name,
        'colorVariants'     : _variants.map((v) => v.toJson()).toList(),
        'companyId'         : _companyId,
        'email'             : _email,
        'storeName'         : _storeName,
        'tags'              : _tags,
        'updatedAt'         : FieldValue.serverTimestamp(),
      };

      if (widget.productId == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      await FirebaseFirestore.instance
          .collection('products')
          .doc(id)
          .set(data, SetOptions(merge: true));

      Get.back();
    } catch (e, st) {
      Get.snackbar('Error', e.toString());
    }
  }

  // Delete product
  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete product?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),  child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final id     = widget.productId!;
      final docRef = FirebaseFirestore.instance.collection('products').doc(id);
      final snap   = await docRef.get();
      final imgs   = List<String>.from(snap.data()?['productImages'] ?? []);

      for (final url in imgs) {
        try { await FirebaseStorage.instance.refFromURL(url).delete(); } catch (_) {}
      }

      await docRef.delete();
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)       return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(body: Center(child: Text('Error: $_error')));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId == null ? 'Add Product' : 'Edit Product'),
        actions: widget.productId != null
            ? [IconButton(icon: const Icon(Icons.delete), onPressed: _deleteProduct)]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _nameC,    decoration: const InputDecoration(labelText: 'Product name')),
            TextField(controller: _descC,    decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
            TextField(controller: _deliveryC,decoration: const InputDecoration(labelText: 'Delivery time (days)'), keyboardType: TextInputType.number),
            TextField(controller: _priceC,   decoration: const InputDecoration(labelText: 'Price (OMR)'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 16),

            // Select category
            Obx(() => ElevatedButton(
              onPressed: () async {
                final res = await Get.to<ProductCategoryModel?>(() => const ProductCategorySelectionPage());
                if (res != null) _catCtrl.selected.value = res;
              },
              child: Text(_catCtrl.selected.value?.name ?? 'Select Category'),
            )),
            const SizedBox(height: 16),

            const Text('Tags', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ..._tags.map((tag) => Chip(
                  label: Text(tag),
                  onDeleted: () => setState(() => _tags.remove(tag)),
                )),
                ActionChip(label: const Text('+ Add Tag'), onPressed: _showAddTagDialog),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Color Variants', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add), onPressed: _showAddVariantDialog),
              ],
            ),
            if (_variants.isEmpty) const Text('No variants added.'),
            if (_variants.isNotEmpty)
              Column(
                children: _variants.map((v) {
                  return ListTile(
                    title: Text(v.color),
                    subtitle: Text('Quantity: ${v.quantity}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit),   onPressed: () => _showEditVariantDialog(v)),
                        IconButton(icon: const Icon(Icons.delete), onPressed: () => setState(() => _variants.remove(v))),
                      ],
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 16),

            const Text('Images', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._existingImageUrls.map((url) => Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.network(url, width: 60, height: 60, fit: BoxFit.cover),
                    GestureDetector(
                      onTap: () async {
                        setState(() => _existingImageUrls.remove(url));
                        try { await FirebaseStorage.instance.refFromURL(url).delete(); } catch (_) {}
                      },
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                )),
                ..._pickedImages.map((x) =>
                    Image.file(File(x.path), width: 60, height: 60, fit: BoxFit.cover)),
                IconButton(onPressed: _pickImages, icon: const Icon(Icons.add_a_photo)),
              ],
            )),

            const SizedBox(height: 24),

            // Submit
            ElevatedButton(
              onPressed: _submit,
              child: Text(widget.productId == null ? 'Upload product' : 'Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}