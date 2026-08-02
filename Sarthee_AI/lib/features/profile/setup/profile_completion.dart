import 'package:flutter/foundation.dart';
import '../domain/entities/profile_entity.dart';

/// Validates backend profile completeness before entering Home.
bool isProfileComplete(ProfileEntity? profile) {
  debugPrint("========== PROFILE CHECK ==========");

  if (profile == null) {
    debugPrint("profile == null");
    return false;
  }

  debugPrint("firebaseUid: '${profile.firebaseUid}'");
  debugPrint("email: '${profile.email}'");
  debugPrint("name: '${profile.name}'");
  debugPrint("language: '${profile.preferences.language}'");
  debugPrint("city: '${profile.location.city}'");
  debugPrint("gender: '${profile.profile.gender}'");
  debugPrint("dob: '${profile.profile.dob}'");

  if (profile.firebaseUid.trim().isEmpty) {
    debugPrint("FAILED: firebaseUid");
    return false;
  }

  if (profile.email.trim().isEmpty) {
    debugPrint("FAILED: email");
    return false;
  }

  if (profile.name.trim().isEmpty) {
    debugPrint("FAILED: name");
    return false;
  }

  if ((profile.preferences.language ?? '').trim().isEmpty) {
    debugPrint("FAILED: language");
    return false;
  }

  if ((profile.location.city ?? '').trim().isEmpty) {
    debugPrint("FAILED: city");
    return false;
  }

  if ((profile.profile.gender ?? '').trim().isEmpty) {
    debugPrint("FAILED: gender");
    return false;
  }

  if ((profile.profile.dob ?? '').trim().isEmpty) {
    debugPrint("FAILED: dob");
    return false;
  }

  debugPrint("PROFILE COMPLETE = TRUE");
  return true;
}