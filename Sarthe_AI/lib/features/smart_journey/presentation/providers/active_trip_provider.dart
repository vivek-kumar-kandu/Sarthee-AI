import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/journey_plan.dart';
import '../../domain/entities/journey_session.dart';
import '../../domain/usecases/active_trip_tracker.dart';
import 'smart_journey_provider.dart';

final activeTripTrackerProvider = Provider((ref) {
  final repo = ref.watch(journeyRepositoryProvider);
  return ActiveTripTracker(repo);
});

class ActiveTripNotifier extends StateNotifier<AsyncValue<JourneySession?>> {
  final ActiveTripTracker _tracker;

  ActiveTripNotifier(this._tracker) : super(const AsyncValue.data(null));

  Future<void> startTrip(JourneyPlan plan) async {
    state = const AsyncValue.loading();
    try {
      final session = await _tracker.startTrip(plan);
      state = AsyncValue.data(session);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStatus(JourneyStatus newStatus) async {
    final currentSession = state.value;
    if (currentSession == null) return;

    try {
      final updated = await _tracker.updateStatus(
        sessionId: currentSession.sessionId,
        status: newStatus,
      );
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void cancelTrip() {
    state = const AsyncValue.data(null);
  }

  void nextStep() {
    final currentSession = state.value;
    if (currentSession == null) return;

    final nextIndex = currentSession.currentStepIndex + 1;
    if (nextIndex < currentSession.plan.steps.length) {
      final updated = currentSession.copyWith(currentStepIndex: nextIndex);
      state = AsyncValue.data(updated);
    } else {
      updateStatus(JourneyStatus.completed);
      state = const AsyncValue.data(null);
    }
  }
}

final activeTripProvider = StateNotifierProvider<ActiveTripNotifier, AsyncValue<JourneySession?>>((ref) {
  final tracker = ref.watch(activeTripTrackerProvider);
  return ActiveTripNotifier(tracker);
});
