import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ColorVariantPicker extends StatefulWidget {
  final String productId;
  final Color? initialColor;
  final ValueChanged<Color> onColorSelected;

  const ColorVariantPicker({
    super.key,
    required this.productId,
    this.initialColor,
    required this.onColorSelected,
  });

  @override
  _ColorVariantPickerState createState() => _ColorVariantPickerState();
}

class _ColorVariantPickerState extends State<ColorVariantPicker> {

  Color? _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(

      // Load document
      future: FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get(),
      builder: (context, snap) {

        if (snap.connectionState != ConnectionState.done ||
            !snap.hasData ||
            !snap.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snap.data!.data()!;
        final raw = data['colorVariants'] as List<dynamic>?;

        // If no variants render nothing
        if (raw == null || raw.isEmpty) {
          return const SizedBox.shrink();
        }

        // Change hex string to color
        final variants = raw!
            .cast<Map<String, dynamic>>()
            .map((entry) {
          final hex = entry['color'] as String;

          final clean = hex.replaceFirst('0x', '');
          final value = int.parse(clean, radix: 16);
          final c = Color(value);
          return c;
        }).toList();

        _selectedColor ??= variants.first;

        // UI
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Selection Title
              Text('Available colors',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),

              // Display in row
              Row(
                children: variants.map((color) {
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () => {
                      setState(() => _selectedColor = color),
                  widget.onColorSelected(color),
                },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: isSelected ? 36 : 30,
                      height: isSelected ? 36 : 30,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,

                        // Add boarder for selected color
                        border: isSelected
                            ? Border.all(width: 2, color: Colors.black)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
