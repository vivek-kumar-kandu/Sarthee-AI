import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/responsive/app_responsive.dart';
import '../../auth/widgets/auth_loading_widget.dart';
import '../domain/entities/profile_entity.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_section_card.dart';
import '../widgets/travel_chip_selector.dart';

/// Sarthee AI Edit Profile Page allowing comprehensive profile editing.
///
/// Features:
/// • Pre-fills all existing profile fields
/// • Avatar photo preview & initial fallback badge
/// • Saves only changed values
/// • Fully responsive & accessible
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _cityController;

  String? _gender;
  String _language = "English";
  DateTime? _dob;
  bool _saving = false;

  List<String> _selectedInterests = <String>[];
  String? _selectedPace;
  String? _selectedCompanion;
  String? _selectedDiet;
  String? _selectedBudget;
  String? _selectedTransport;

  static const List<String> _languages = <String>["English", "Hindi", "French", "Spanish", "German"];
  static const List<String> _genders = <String>["Male", "Female", "Other", "Prefer not to say"];
  static const List<String> _interestOptions = <String>[
    "Mountains", "Beaches", "Heritage", "Food", "Adventure", "Wildlife", "Photography", "Shopping"
  ];
  static const List<String> _paceOptions = <String>["Fast", "Balanced", "Relaxed"];
  static const List<String> _companionOptions = <String>["Solo", "Couple", "Family", "Friends"];
  static const List<String> _dietOptions = <String>["Veg", "Eggitarian", "Non-Veg", "Vegan", "Jain"];
  static const List<String> _budgetOptions = <String>["Budget", "Mid-Range", "Luxury"];
  static const List<String> _transportOptions = <String>["Train", "Flight", "Road Trip", "Any"];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).value;

    _nameController = TextEditingController(text: profile?.name ?? "");
    _bioController = TextEditingController(text: profile?.profile.bio ?? "");
    _cityController = TextEditingController(text: profile?.location.city ?? "");
    _gender = profile?.profile.gender;
    _language = profile?.preferences.language ?? "English";

    if (profile?.profile.dob != null && profile!.profile.dob!.isNotEmpty) {
      _dob = DateTime.tryParse(profile.profile.dob!);
    }

    _selectedInterests = List<String>.from(profile?.profile.travelInterests ?? <String>[]);
    _selectedPace = profile?.profile.travelPace;
    _selectedCompanion = profile?.profile.companionPreference;
    _selectedDiet = profile?.preferences.dietaryPreference;
    _selectedBudget = profile?.preferences.budgetTier;
    _selectedTransport = profile?.preferences.preferredTransport;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  Future<void> _save(ProfileEntity profile) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final updated = profile.copyWith(
        name: _nameController.text.trim(),
        profile: profile.profile.copyWith(
          bio: _bioController.text.trim(),
          gender: _gender,
          dob: _dob?.toIso8601String(),
          travelInterests: _selectedInterests,
          travelPace: _selectedPace,
          companionPreference: _selectedCompanion,
        ),
        location: profile.location.copyWith(city: _cityController.text.trim()),
        preferences: profile.preferences.copyWith(
          language: _language,
          dietaryPreference: _selectedDiet,
          budgetTier: _selectedBudget,
          preferredTransport: _selectedTransport,
        ),
      );

      await ref.read(profileProvider.notifier).updateProfile(updated);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: Color(0xFF0D9488),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update profile: $e"),
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
          "Edit Profile",
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
          child: Text("Error: $error"),
        ),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text("No profile available"));
          }

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
                        // Avatar Photo Preview & Placeholder Header
                        Center(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primaryColor.withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: primaryColor,
                                    width: 2,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: profile.picture != null && profile.picture!.isNotEmpty
                                    ? Image.network(
                                        profile.picture!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            _buildAvatarInitial(profile.name),
                                      )
                                    : _buildAvatarInitial(profile.name),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0D9488),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Section 1: Basic Information
                        ProfileSectionCard(
                          title: 'Basic Information',
                          icon: Icons.person_outline_rounded,
                          iconColor: primaryColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Name required';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _cityController,
                                decoration: InputDecoration(
                                  labelText: 'Home City',
                                  prefixIcon: const Icon(Icons.location_city_outlined),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                              const SizedBox(height: 14),
                              DropdownButtonFormField<String>(
                                initialValue: _language,
                                decoration: InputDecoration(
                                  labelText: 'Preferred Language',
                                  prefixIcon: const Icon(Icons.translate_rounded),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                items: _languages
                                    .map((lang) => DropdownMenuItem<String>(
                                          value: lang,
                                          child: Text(lang),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _language = val);
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _bioController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: 'Personal Bio',
                                  hintText: 'Tell fellow travelers about yourself...',
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                              const SizedBox(height: 14),
                              InkWell(
                                onTap: _pickDate,
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Date of Birth',
                                    prefixIcon: const Icon(Icons.calendar_today_rounded),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(
                                    _dob != null
                                        ? '${_dob!.day}/${_dob!.month}/${_dob!.year}'
                                        : 'Select Date of Birth',
                                    style: TextStyle(
                                      color: _dob != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              _buildSubHeader('Gender'),
                              const SizedBox(height: 8),
                              TravelChipSelector(
                                options: _genders,
                                selectedValues: _gender != null ? <String>[_gender!] : <String>[],
                                onChanged: (vals) => setState(() => _gender = vals.isNotEmpty ? vals.first : null),
                              ),
                            ],
                          ),
                        ),

                        // Section 2: Travel Persona
                        ProfileSectionCard(
                          title: 'Travel Persona',
                          icon: Icons.travel_explore_rounded,
                          iconColor: const Color(0xFF0D9488),
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
                              const SizedBox(height: 16),
                              _buildSubHeader('Travel Pace'),
                              const SizedBox(height: 8),
                              TravelChipSelector(
                                options: _paceOptions,
                                selectedValues: _selectedPace != null ? <String>[_selectedPace!] : <String>[],
                                onChanged: (vals) => setState(() => _selectedPace = vals.isNotEmpty ? vals.first : null),
                              ),
                              const SizedBox(height: 16),
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

                        // Section 3: Travel Preferences
                        ProfileSectionCard(
                          title: 'Travel Preferences',
                          icon: Icons.tune_rounded,
                          iconColor: const Color(0xFFF59E0B),
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
                              const SizedBox(height: 16),
                              _buildSubHeader('Budget Tier'),
                              const SizedBox(height: 8),
                              TravelChipSelector(
                                options: _budgetOptions,
                                selectedValues: _selectedBudget != null ? <String>[_selectedBudget!] : <String>[],
                                onChanged: (vals) => setState(() => _selectedBudget = vals.isNotEmpty ? vals.first : null),
                              ),
                              const SizedBox(height: 16),
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

                        const SizedBox(height: 24),

                        // Save Button (Pill CTA)
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
                              onPressed: _saving ? null : () => _save(profile),
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
                                  : const Text('Save Profile Changes →'),
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

  Widget _buildAvatarInitial(String name) {
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
    return Container(
      color: const Color(0xFF312E81),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w800,
        ),
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
