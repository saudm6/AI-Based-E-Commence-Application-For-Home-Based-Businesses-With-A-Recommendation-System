import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LikeButton extends StatefulWidget {
  final String productId;
  final String storeName;
  final String productTitle;
  final double price;

  const LikeButton({
    super.key,
    required this.productId,
    required this.storeName,
    required this.productTitle,
    required this.price,
  });

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  late final DocumentReference _likeRef;
  bool _isLiked = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    final uid = FirebaseAuth.instance.currentUser!.uid;
    _likeRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('likes')
        .doc(widget.productId);

    // Check initial like status
    _checkLiked();
  }

  // Check if liked
  Future<void> _checkLiked() async {
    final snap = await _likeRef.get();
    setState(() {
      _isLiked = snap.exists;
      _loading = false;
    });
  }

  // Toggles the like state
  Future<void> _toggleLike() async {
    setState(() => _loading = true);

    if (_isLiked) {
      await _likeRef.delete();
    } else {

      await _likeRef.set({
        'likedAt': FieldValue.serverTimestamp(),
        'storeName': widget.storeName,
        'productTitle': widget.productTitle,
        'price': widget.price,
      });
    }

    setState(() {
      _isLiked = !_isLiked;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    // Display loading
    if (_loading) {
      return const SizedBox(
        width: 24, height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    // Display liked icon
    return IconButton(
      icon: Icon(
        _isLiked ? Icons.favorite : Icons.favorite_border,
        color: _isLiked ? Colors.red : null,
      ),
      onPressed: _toggleLike,
    );
  }
}
