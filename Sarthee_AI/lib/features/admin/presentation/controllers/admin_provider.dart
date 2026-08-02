import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';

class AdminState {
  final bool isLoading;
  final Map<String, dynamic>? snapshot;
  final Meta? meta;
  final String? error;

  const AdminState({
    this.isLoading = false,
    this.snapshot,
    this.meta,
    this.error,
  });

  AdminState copyWith({
    bool? isLoading,
    Map<String, dynamic>? snapshot,
    Meta? meta,
    String? error,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      snapshot: snapshot ?? this.snapshot,
      meta: meta ?? this.meta,
      error: error,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  AdminNotifier() : super(const AdminState()) {
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ApiClient.instance.dio.get('/admin/dashboard');
      final json = response.data as Map<String, dynamic>;
      
      Meta? parsedMeta;
      if (json.containsKey('meta') && json['meta'] is Map<String, dynamic>) {
        parsedMeta = Meta.fromJson(json['meta'] as Map<String, dynamic>);
      }

      state = state.copyWith(
        isLoading: false,
        snapshot: json,
        meta: parsedMeta,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier();
});
