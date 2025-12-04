import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/review.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';

class ReviewListPage extends StatefulWidget {
  final int listingId;

  const ReviewListPage({Key? key, required this.listingId}) : super(key: key);

  @override
  State<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
  late DatabaseHelper _dbHelper;
  List<Review> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await _dbHelper.getReviewsByListing(widget.listingId);
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (c) => _AddReviewDialog(
        listingId: widget.listingId,
        dbHelper: _dbHelper,
        onReviewAdded: _loadReviews,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_reviews.length} Reviews',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ElevatedButton.icon(
                onPressed: _showAddReviewDialog,
                icon: const Icon(Icons.add),
                label: const Text('Beri Review'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_reviews.isEmpty)
            Center(
              child: Column(
                children: const [
                  Icon(Icons.rate_review, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada review'),
                ],
              ),
            )
          else
            ..._reviews.map((review) => _buildReviewCard(review)).toList(),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rating: ${review.rating}/5',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              Text(
                review.createdAt.toString().split(' ')[0],
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (review.comment.isNotEmpty)
            Text(review.comment, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }
}

class _AddReviewDialog extends StatefulWidget {
  final int listingId;
  final DatabaseHelper dbHelper;
  final VoidCallback onReviewAdded;

  const _AddReviewDialog({
    required this.listingId,
    required this.dbHelper,
    required this.onReviewAdded,
  });

  @override
  State<_AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<_AddReviewDialog> {
  late TextEditingController _commentController;
  int _rating = 5;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  Future<void> _submitReview() async {
    try {
      final review = Review(
        id: 0,
        listingId: widget.listingId,
        studentId: AuthService().userId,
        rating: _rating.toDouble(),
        title: 'Review',
        comment: _commentController.text,
        createdAt: DateTime.now(),
      );

      await widget.dbHelper.insertReview(review);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review berhasil ditambahkan')),
        );
        Navigator.pop(context);
        widget.onReviewAdded();
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Beri Review'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Rating', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Icon(
                    Icons.star,
                    color: i < _rating ? Colors.amber : Colors.grey[300],
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Komentar (opsional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _submitReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
          child: const Text('Kirim'),
        ),
      ],
    );
  }
}
