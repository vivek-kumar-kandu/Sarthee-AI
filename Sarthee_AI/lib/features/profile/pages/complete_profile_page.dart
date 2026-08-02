import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/responsive/app_responsive.dart';
import '../../auth/widgets/auth_loading_widget.dart';
import '../domain/entities/profile_entity.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_section_card.dart';
import '../widgets/travel_chip_selector.dart';

/// Complete Profile Enrichment Flow (/profile/complete).
///
/// Features:
/// • Modular sections: Travel Persona, Travel Preferences, & Personal Details
/// • Reusable TravelChipSelector & ProfileSectionCard components
/// • Real-time dynamic completion percentage calculation
/// • Only saves changed values upon user save action
class CompleteProfilePage extends ConsumerStatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  ConsumerState<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends ConsumerState<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _bioController;
  late TextEditingController _cityController;

  List<String> _selectedInterests = <String>[];
  String? _selectedPace;
  String? _selectedCompanion;
  String? _selectedDiet;
  String? _selectedBudget;
  String? _selectedTransport;
  String? _gender;

  bool _saving = false;

  static const List<String> _interestOptions = <String>[
    "Mountains",
    "Beaches",
    "Heritage",
    "Food",
    "Adventure",
    "Wildlife",
    "Photography",
    "Shopping",
  ];

  static const List<String> _paceOptions = <String>[
    "Fast",
    "Balanced",
    "Relaxed",
  ];

  static const List<String> _companionOptions = <String>[
    "Solo",
    "Couple",
    "Family",
    "Friends",
  ];

  static const List<String> _dietOptions = <String>[
    "Veg",
    "Eggitarian",
    "Non-Veg",
    "Vegan",
    "Jain",
  ];

  static const List<String> _budgetOptions = <String>[
    "Budget",
    "Mid-Range",
    "Luxury",
  ];

  static const List<String> _transportOptions = <String>[
    "Train",
    "Flight",
    "Road Trip",
    "Any",
  ];

  static const List<String> _genderOptions = <String>[
    "Male",
    "Female",
    "Other",
    "Prefer not to say",
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).value;

    _bioController = TextEditingController(text: profile?.profile.bio ?? "");
    _cityController = TextEditingController(text: profile?.location.city ?? "");

    _selectedInterests = List<String>.from(profile?.profile.travelInterests ?? <String>[]);
    _selectedPace = profile?.profile.travelPace;
    _selectedCompanion = profile?.profile.companionPreference;
    _selectedDiet = profile?.preferences.dietaryPreference;
    _selectedBudget = profile?.preferences.budgetTier;
    _selectedTransport = profile?.preferences.preferredTransport;
    _gender = profile?.profile.gender;
  }

  @override
  void dispose() {
    _bioController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _saveEnrichedProfile(ProfileEntity currentProfile) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final updated = currentProfile.copyWith(
        location: currentProfile.location.copyWith(
          city: _cityController.text.trim(),
        ),
        profile: currentProfile.profile.copyWith(
          bio: _bioController.text.trim(),
          gender: _gender,
          travelInterests: _selectedInterests,
          travelPace: _selectedPace,
          companionPreference: _selectedCompanion,
        ),
        preferences: currentProfile.preferences.copyWith(
          dietaryPreference: _selectedDiet,
          budgetTier: _selectedBudget,
          preferredTransport: _selectedTransport,
        ),
      );

      await ref.read(profileProvider.notifier).updateProfile(updated);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile preferences saved successfully!"),
          backgroundColor: Color(0xFF0D9488),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save profile: $e"),
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
    final Color primaryColor = const Color(0xFF4F46E5);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Complete Profile",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: profileAsync.when(
        loading: () => const AuthLoadingWidget(),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFDC2626)),
              const SizedBox(height: 12),
              Text('Unable to load profile data: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(profileProvider.notifier).loadProfile(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text("No profile data available."));
          }

          // Dynamic calculation preview
          final previewEntity = profile.copyWith(
            location: profile.location.copyWith(city: _cityController.text.trim()),
            profile: profile.profile.copyWith(
              bio: _bioController.text.trim(),
              gender: _gender,
              travelInterests: _selectedInterests,
              travelPace: _selectedPace,
              companionPreference: _selectedCompanion,
            ),
            preferences: profile.preferences.copyWith(
              dietaryPreference: _selectedDiet,
              budgetTier: _selectedBudget,
              preferredTransport: _selectedTransport,
            ),
          );

          final double completionFraction = previewEntity.completionPercentage;
          final int completionPercent = (completionFraction * 100).round();

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: AppResponsive.screenPadding(context),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Real-Time Progress Card
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: <Widget>[
                              CircularProgressIndicator(
                                value: completionFraction,
                                strokeWidth: 5,
                                backgroundColor: primaryColor.withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Profile Completeness: $completionPercent%',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Complete details to receive tailored AI recommendations',
                                      style: TextStyle(
                                        color: Color(0xFF475569),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Section 1: Travel Persona
                        ProfileSectionCard(
                          title: 'Travel Persona',
                          icon: Icons.travel_explore_rounded,
                          iconColor: const Color(0xFF0D9488),
                          subtitle: 'Tell Sarthee AI how you love to explore',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _buildSubHeader('Travel Interests'),
                              const SizedBox(height: 8),
                              TravelChipSelector(
                                options: _interestOptions,
                                selectedValues: _selectedInterests,
                                isMultiSelect: true,
                                onChanged: (vals) => setState(() => _selectedInterests = vals),
                              ),
                              const SizedBox(height: 18),
                              _buildSubHeader('Travel Pace'),
                              const SizedBox(height: 8),
                              TravelChipSelector(
                                options: _paceOptions,
                                selectedValues: _selectedPace != null ? <String>[_selectedPace!] : <String>[],
                                onChanged: (vals) => setState(() => _selectedPace = vals.isNotEmpty ? vals.first : null),
                              ),
                              const SizedBox(height: 18),
                              _buildSubHeader('Companion Preference'),
                              const SizedBox(height: 8),
                              TravelChipSelector(
                                options: _companionOptions,
                                selectedValues: _selectedCompanion != null ? <String>[_selectedCompanion!] : <String>[],
                                onChanged: (vals) => setState(() => _selectedCompanion = vals.isNotEmpty ? vals.first : null),
                              ),
                            ],
                          ),
                        ),

                        // Section 2: Travel Preferences
                        ProfileSectionCard(
                          title: 'Travel Preferences',
                          icon: Icons.tune_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          subtitle: 'Dietary habits, transport, and budget tier',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _buildSubHeader('Dietary Preference'),
                              const SizedBox(height: 8),
                              TravelChipSelector(
                                options: _dietOptions,
                                selectedValues: _selectedDiet != null ? <String>[_selectedDiet!] : <String>[],
                                onChanged: (vals) => setState(() => _selectedDiet = vals.isNotEmpty ? vals.first : null),
                              ),
                              const SizedBox(height: 18),
                              _buildSubHeader('Budget Tier'),
                              const SizedBox(height: 8),
                              TravelChipSelector(
                                options: _budgetOptions,
                                selectedValues: _selectedBudget != null ? <String>[_selectedBudget!] : <String>[],
                                onChanged: (vals) => setState(() => _selectedBudget = vals.isNotEmpty ? vals.first : null),
                              ),
                              const SizedBox(height: 18),
                              _buildSubHeader('Preferred Transport'),
                              const SizedBox(height: 8),
                              TravelChipSelector(
                                options: _transportOptions,
                                selectedValues: _selectedTransport != null ? <String>[_selectedTransport!] : <String>[],
                                onChanged: (vals) => setState(() => _selectedTransport = vals.isNotEmpty ? vals.first : null),
                              ),
                            ],
                          ),
                        ),

                        // Section 3: Personal Details
                        ProfileSectionCard(
                          title: 'Personal Details',
                          icon: Icons.person_outline_rounded,
                          iconColor: primaryColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              TextFormField(
                                controller: _cityController,
                                decoration: InputDecoration(
                                  labelText: 'Home City',
                                  prefixIcon: const Icon(Icons.location_city_outlined),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _bioController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: 'Personal Bio',
                                  hintText: 'Share a short snippet about yourself...',
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                              const SizedBox(height: 14),
                              _buildSubHeader('Gender'),
                              const SizedBox(height: 8),
                              TravelChipSelector(
                                options: _genderOptions,
                                selectedValues: _gender != null ? <String>[_gender!] : <String>[],
                                onChanged: (vals) => setState(() => _gender = vals.isNotEmpty ? vals.first : null),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Save Preferences Button (Pill CTA)
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
                              onPressed: _saving ? null : () => _saveEnrichedProfile(profile),
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
                                  : const Text('Save Profile Preferences →'),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
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

  Widget _buildSubHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF334155),
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }
}
