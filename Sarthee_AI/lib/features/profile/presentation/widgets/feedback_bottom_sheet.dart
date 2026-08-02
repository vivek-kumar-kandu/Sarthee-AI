import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'feedback_provider.dart';

class FeedbackBottomSheet extends ConsumerStatefulWidget {
  const FeedbackBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FeedbackBottomSheet(),
    );
  }

  @override
  ConsumerState<FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends ConsumerState<FeedbackBottomSheet> {
  int _overallRating = 5;
  final int _journeyAccuracy = 5;
  final int _nearbyAccuracy = 5;
  final int _performance = 5;
  String _category = 'general';
  final TextEditingController _commentsController = TextEditingController();

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedbackProvider);
    final notifier = ref.read(feedbackProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Send Feedback',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Overall Rating Stars
              const Text('Overall Experience', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  final starVal = index + 1;
                  return IconButton(
                    icon: Icon(
                      starVal <= _overallRating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: const Color(0xFFEAB308),
                      size: 32,
                    ),
                    onPressed: () => setState(() => _overallRating = starVal),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Category Selector
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Feedback Category',
                  border: OutlineInputBorder(),
                ),

                items: const [
                  DropdownMenuItem(value: 'general', child: Text('General Feedback')),
                  DropdownMenuItem(value: 'journey', child: Text('Smart Journey Engine')),
                  DropdownMenuItem(value: 'nearby', child: Text('Nearby POI Discovery')),
                  DropdownMenuItem(value: 'ui', child: Text('UI / UX Design')),
                  DropdownMenuItem(value: 'bug', child: Text('Bug Report')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
              const SizedBox(height: 16),

              // Comments Field
              TextField(
                controller: _commentsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Comments & Suggestions',
                  hintText: 'Let us know how we can improve Sarthee AI...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              if (state.error != null) ...[
                Text(state.error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                const SizedBox(height: 12),
              ],

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: state.isSubmitting
                      ? null
                      : () async {
                          final success = await notifier.submitFeedback(
                            rating: _overallRating,
                            journeyAccuracyRating: _journeyAccuracy,
                            nearbyAccuracyRating: _nearbyAccuracy,
                            performanceRating: _performance,
                            category: _category,
                            comments: _commentsController.text.trim(),
                          );
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Thank you for your feedback!')),
                            );
                            Navigator.of(context).pop();
                          }
                        },
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Submit Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
