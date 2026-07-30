import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../../core/responsive/app_responsive.dart';
import '../../auth/auth_provider.dart';
import '../../auth/widgets/auth_loading_widget.dart';
import '../domain/entities/profile_entity.dart';
import '../providers/profile_provider.dart';

/// Sarthee AI Quick Profile Setup Screen (<15 seconds completion target).
///
/// Collects only the essential minimum fields for instant app entry:
/// • Full Name
/// • Home City
/// • Preferred Language (English / Hindi)
class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _cityController;

  String _language = "English";
  bool _saving = false;

  static const List<String> _languages = ["English", "Hindi"];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).value;
    final authUser = ref.read(authUserProvider);

    _nameController = TextEditingController(
      text: profile?.name ?? authUser?.name ?? "",
    );
    _cityController = TextEditingController(
      text: profile?.location.city ?? "",
    );
    _language = profile?.preferences.language ?? "English";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _saveQuickProfile(ProfileEntity currentProfile) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final updated = currentProfile.copyWith(
        name: _nameController.text.trim(),
        location: currentProfile.location.copyWith(
          city: _cityController.text.trim(),
        ),
        preferences: currentProfile.preferences.copyWith(
          language: _language,
        ),
      );

      await ref.read(profileProvider.notifier).updateProfile(updated);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Welcome to Sarthee AI! Profile setup complete."),
          backgroundColor: Color(0xFF0D9488),
        ),
      );

      context.go(RoutePaths.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Setup failed: $e"),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = const Color(0xFF4F46E5);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Quick Setup',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: profileAsync.when(
        loading: () => const AuthLoadingWidget(),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFDC2626)),
              const SizedBox(height: 12),
              Text('Unable to load profile data: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(profileProvider.notifier).loadProfile(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (profile) {
          final effectiveProfile = profile ??
              ProfileEntity(
                id: 'temp',
                firebaseUid: 'temp',
                email: '',
                name: _nameController.text,
                picture: null,
                role: 'user',
                profile: const UserProfile(),
                location: UserLocation(city: _cityController.text),
                preferences: UserPreferences(language: _language),
                isActive: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                lastLoginAt: DateTime.now(),
              );

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: AppResponsive.screenPadding(context),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 8),

                        // Header Icon Badge
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor.withValues(alpha: 0.1),
                          ),
                          child: Icon(
                            Icons.person_pin_circle_rounded,
                            size: 36,
                            color: primaryColor,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'Let\'s personalize Sarthee AI',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFF1E293B),
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Enter 3 quick details to unlock your travel experience in seconds',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF64748B),
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Star Divider: ──── ✦ ────
                        Opacity(
                          opacity: 0.40,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: 44,
                                child: Divider(thickness: 1.5, color: primaryColor),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.star_rounded, size: 10, color: primaryColor),
                              ),
                              SizedBox(
                                width: 44,
                                child: Divider(thickness: 1.5, color: primaryColor),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // 1. Full Name Input
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'Enter your full name',
                            prefixIcon: const Icon(Icons.person_outline_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Full name required';
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // 2. Home City Input
                        TextFormField(
                          controller: _cityController,
                          decoration: InputDecoration(
                            labelText: 'Home City',
                            hintText: 'e.g. New Delhi, Mumbai, Jaipur',
                            prefixIcon: const Icon(Icons.location_city_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Home city required';
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // 3. Preferred Language Selector
                        DropdownButtonFormField<String>(
                          initialValue: _language,
                          decoration: InputDecoration(
                            labelText: 'Preferred Language',
                            prefixIcon: const Icon(Icons.translate_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: _languages
                              .map((lang) => DropdownMenuItem<String>(
                                    value: lang,
                                    child: Text(lang),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _language = val);
                            }
                          },
                        ),

                        const SizedBox(height: 32),

                        // Complete & Unlock Button (Pill CTA)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.30),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _saving ? null : () => _saveQuickProfile(effectiveProfile),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: _saving
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Complete & Start Exploring →'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
