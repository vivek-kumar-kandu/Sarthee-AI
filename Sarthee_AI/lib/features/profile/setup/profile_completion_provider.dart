import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/profile_provider.dart' as profile_lib;
import 'profile_completion.dart';

/// Indicates whether the current cached/loaded profile is considered complete.
final profileCompletionProvider = Provider<bool>((ref) {
  final profile = ref.watch(profile_lib.profileProvider).valueOrNull;

  return isProfileComplete(profile);
});
