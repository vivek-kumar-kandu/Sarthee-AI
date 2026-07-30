import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/journey_plan.dart';
import '../../domain/usecases/plan_smart_journey.dart';
import '../../data/repositories/journey_repository_impl.dart';

final journeyRepositoryProvider = Provider((ref) {
  return JourneyRepositoryImpl();
});

final planSmartJourneyProvider = Provider((ref) {
  final repo = ref.watch(journeyRepositoryProvider);
  return PlanSmartJourney(repo);
});

class SmartJourneyState {
  final bool isLoading;
  final String origin;
  final String destination;
  final List<JourneyPlan> plans;
  final RecommendationMode selectedMode;
  final String? errorMessage;

  const SmartJourneyState({
    this.isLoading = false,
    this.origin = "Ghaziabad (Current Location)",
    this.destination = "Connaught Place, Delhi",
    this.plans = const [],
    this.selectedMode = RecommendationMode.balanced,
    this.errorMessage,
  });

  SmartJourneyState copyWith({
    bool? isLoading,
    String? origin,
    String? destination,
    List<JourneyPlan>? plans,
    RecommendationMode? selectedMode,
    String? errorMessage,
  }) {
    return SmartJourneyState(
      isLoading: isLoading ?? this.isLoading,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      plans: plans ?? this.plans,
      selectedMode: selectedMode ?? this.selectedMode,
      errorMessage: errorMessage,
    );
  }

  JourneyPlan? get selectedPlan {
    if (plans.isEmpty) return null;
    try {
      return plans.firstWhere((p) => p.mode == selectedMode);
    } catch (_) {
      return plans.first;
    }
  }
}

class SmartJourneyNotifier extends StateNotifier<SmartJourneyState> {
  final PlanSmartJourney _planSmartJourney;

  SmartJourneyNotifier(this._planSmartJourney) : super(const SmartJourneyState()) {
    // Automatically search default route on load
    searchJourney();
  }

  Future<void> searchJourney({String? origin, String? destination}) async {
    final searchOrigin = origin ?? state.origin;
    final searchDest = destination ?? state.destination;

    state = state.copyWith(isLoading: true, origin: searchOrigin, destination: searchDest, errorMessage: null);

    try {
      final results = await _planSmartJourney(
        originName: searchOrigin,
        originLat: 28.6715,
        originLng: 77.4121,
        destinationName: searchDest,
        destinationLat: 28.6328,
        destinationLng: 77.2197,
      );

      state = state.copyWith(isLoading: false, plans: results);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Failed to load smart routes: ${e.toString()}");
    }
  }

  void selectMode(RecommendationMode mode) {
    state = state.copyWith(selectedMode: mode);
  }
}

final smartJourneyProvider = StateNotifierProvider<SmartJourneyNotifier, SmartJourneyState>((ref) {
  final planUsecase = ref.watch(planSmartJourneyProvider);
  return SmartJourneyNotifier(planUsecase);
});
