import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bootstrap_result.dart';
import 'bootstrap_service.dart';
import 'bootstrap_state.dart';

/// Notifier providing reactive bootstrap progress state.
class BootstrapNotifier extends Notifier<BootstrapState> {
  @override
  BootstrapState build() {
    return const BootstrapState(phase: BootstrapPhase.uninitialized);
  }

  Future<BootstrapResult> runBootstrap() async {
    final BootstrapResult result = await BootstrapService.instance.performBootstrap(
      onStateChanged: (BootstrapState nextState) {
        state = nextState;
      },
    );
    ref.read(bootstrapResultProvider.notifier).state = result;
    return result;
  }
}

final bootstrapStateProvider =
    NotifierProvider<BootstrapNotifier, BootstrapState>(BootstrapNotifier.new);

final bootstrapResultProvider = StateProvider<BootstrapResult?>((ref) => null);
