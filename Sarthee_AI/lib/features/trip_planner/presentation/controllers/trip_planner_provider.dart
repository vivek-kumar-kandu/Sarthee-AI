import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_response.dart';
import '../../data/datasources/trip_remote_datasource.dart';

class TripPlannerState {
  final bool isLoading;
  final ApiResponse<Map<String, dynamic>>? planResponse;
  final ApiResponse<Map<String, dynamic>>? savedTripsResponse;
  final String? error;

  const TripPlannerState({
    this.isLoading = false,
    this.planResponse,
    this.savedTripsResponse,
    this.error,
  });

  TripPlannerState copyWith({
    bool? isLoading,
    ApiResponse<Map<String, dynamic>>? planResponse,
    ApiResponse<Map<String, dynamic>>? savedTripsResponse,
    String? error,
  }) {
    return TripPlannerState(
      isLoading: isLoading ?? this.isLoading,
      planResponse: planResponse ?? this.planResponse,
      savedTripsResponse: savedTripsResponse ?? this.savedTripsResponse,
      error: error,
    );
  }
}

class TripPlannerNotifier extends StateNotifier<TripPlannerState> {
  TripPlannerNotifier(this._datasource) : super(const TripPlannerState()) {
    loadSavedTrips();
  }

  final TripRemoteDataSource _datasource;

  Future<void> loadSavedTrips() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _datasource.fetchSavedTrips();
      state = state.copyWith(isLoading: false, savedTripsResponse: response);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> planTrip({
    required String rawPrompt,
    String city = 'Jaipur',
    double totalHours = 6.0,
    String persona = 'Family',
    double maxBudget = 1500.0,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _datasource.planTrip(
        rawPrompt: rawPrompt,
        city: city,
        totalHours: totalHours,
        persona: persona,
        maxBudget: maxBudget,
      );
      state = state.copyWith(isLoading: false, planResponse: response);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final tripRemoteDataSourceProvider = Provider<TripRemoteDataSource>((ref) {
  return const TripRemoteDataSource();
});

final tripPlannerProvider =
    StateNotifierProvider<TripPlannerNotifier, TripPlannerState>((ref) {
      final datasource = ref.watch(tripRemoteDataSourceProvider);
      return TripPlannerNotifier(datasource);
    });
