import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_response.dart';
import '../../data/datasources/emergency_remote_datasource.dart';

class EmergencyState {
  final bool isDispatching;
  final ApiResponse<Map<String, dynamic>>? sosResponse;
  final String? error;

  const EmergencyState({
    this.isDispatching = false,
    this.sosResponse,
    this.error,
  });

  EmergencyState copyWith({
    bool? isDispatching,
    ApiResponse<Map<String, dynamic>>? sosResponse,
    String? error,
  }) {
    return EmergencyState(
      isDispatching: isDispatching ?? this.isDispatching,
      sosResponse: sosResponse ?? this.sosResponse,
      error: error,
    );
  }
}

class EmergencyNotifier extends StateNotifier<EmergencyState> {
  EmergencyNotifier(this._datasource) : super(const EmergencyState());

  final EmergencyRemoteDataSource _datasource;

  Future<void> dispatchSos({
    required double lat,
    required double lng,
    String userId = 'guest_user',
    List<String> emergencyContacts = const [],
  }) async {
    state = state.copyWith(isDispatching: true, error: null);
    try {
      final response = await _datasource.dispatchSos(
        lat: lat,
        lng: lng,
        userId: userId,
        emergencyContacts: emergencyContacts,
      );
      state = state.copyWith(isDispatching: false, sosResponse: response);
    } catch (e) {
      state = state.copyWith(isDispatching: false, error: e.toString());
    }
  }
}

final emergencyRemoteDataSourceProvider = Provider<EmergencyRemoteDataSource>((ref) {
  return const EmergencyRemoteDataSource();
});

final emergencyProvider =
    StateNotifierProvider<EmergencyNotifier, EmergencyState>((ref) {
      final datasource = ref.watch(emergencyRemoteDataSourceProvider);
      return EmergencyNotifier(datasource);
    });
