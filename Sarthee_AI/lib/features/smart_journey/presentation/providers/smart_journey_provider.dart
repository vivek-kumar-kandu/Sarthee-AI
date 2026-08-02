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
  final double originLat;
  final double originLng;
  final String destination;
  final double destinationLat;
  final double destinationLng;
  final List<JourneyPlan> plans;
  final RecommendationMode selectedMode;
  final String? errorMessage;

  const SmartJourneyState({
    this.isLoading = false,
    this.origin = "Ghaziabad (Current Location)",
    this.originLat = 28.6715,
    this.originLng = 77.4121,
    this.destination = "Connaught Place, Delhi",
    this.destinationLat = 28.6328,
    this.destinationLng = 77.2197,
    this.plans = const [],
    this.selectedMode = RecommendationMode.balanced,
    this.errorMessage,
  });

  SmartJourneyState copyWith({
    bool? isLoading,
    String? origin,
    double? originLat,
    double? originLng,
    String? destination,
    double? destinationLat,
    double? destinationLng,
    List<JourneyPlan>? plans,
    RecommendationMode? selectedMode,
    String? errorMessage,
  }) {
    return SmartJourneyState(
      isLoading: isLoading ?? this.isLoading,
      origin: origin ?? this.origin,
      originLat: originLat ?? this.originLat,
      originLng: originLng ?? this.originLng,
      destination: destination ?? this.destination,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      plans: plans ?? this.plans,
      selectedMode: selectedMode ?? this.selectedMode,
      errorMessage: errorMessage,
    );
  }

  JourneyPlan? get selectedPlan {
    if (plans.isEmpty) return null;
    if (selectedMode == RecommendationMode.all) return plans.first;
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

  Future<void> searchJourney({
    String? origin,
    double? originLat,
    double? originLng,
    String? destination,
    double? destinationLat,
    double? destinationLng,
  }) async {
    final searchOrigin = origin ?? state.origin;
    final searchOriginLat = originLat ?? state.originLat;
    final searchOriginLng = originLng ?? state.originLng;

    final searchDest = destination ?? state.destination;
    final searchDestLat = destinationLat ?? state.destinationLat;
    final searchDestLng = destinationLng ?? state.destinationLng;

    state = state.copyWith(
      isLoading: true,
      origin: searchOrigin,
      originLat: searchOriginLat,
      originLng: searchOriginLng,
      destination: searchDest,
      destinationLat: searchDestLat,
      destinationLng: searchDestLng,
      errorMessage: null,
    );

    try {
      final results = await _planSmartJourney(
        originName: searchOrigin,
        originLat: searchOriginLat,
        originLng: searchOriginLng,
        destinationName: searchDest,
        destinationLat: searchDestLat,
        destinationLng: searchDestLng,
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
