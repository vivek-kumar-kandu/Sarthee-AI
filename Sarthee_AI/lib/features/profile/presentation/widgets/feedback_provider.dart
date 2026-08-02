import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_response.dart';
import '../../data/datasources/feedback_remote_datasource.dart';

class FeedbackState {
  final bool isSubmitting;
  final ApiResponse<Map<String, dynamic>>? response;
  final String? error;

  const FeedbackState({
    this.isSubmitting = false,
    this.response,
    this.error,
  });

  FeedbackState copyWith({
    bool? isSubmitting,
    ApiResponse<Map<String, dynamic>>? response,
    String? error,
  }) {
    return FeedbackState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      response: response ?? this.response,
      error: error,
    );
  }
}

class FeedbackNotifier extends StateNotifier<FeedbackState> {
  FeedbackNotifier(this._datasource) : super(const FeedbackState());

  final FeedbackRemoteDataSource _datasource;

  Future<bool> submitFeedback({
    int rating = 5,
    int journeyAccuracyRating = 5,
    int nearbyAccuracyRating = 5,
    int performanceRating = 5,
    String category = 'general',
    String comments = '',
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final res = await _datasource.submitFeedback(
        rating: rating,
        journeyAccuracyRating: journeyAccuracyRating,
        nearbyAccuracyRating: nearbyAccuracyRating,
        performanceRating: performanceRating,
        category: category,
        comments: comments,
      );
      state = state.copyWith(isSubmitting: false, response: res);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }
}

final feedbackRemoteDataSourceProvider = Provider<FeedbackRemoteDataSource>((ref) {
  return const FeedbackRemoteDataSource();
});

final feedbackProvider =
    StateNotifierProvider<FeedbackNotifier, FeedbackState>((ref) {
      final datasource = ref.watch(feedbackRemoteDataSourceProvider);
      return FeedbackNotifier(datasource);
    });
