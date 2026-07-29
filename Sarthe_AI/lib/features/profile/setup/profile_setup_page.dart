import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../auth/auth_provider.dart';
import '../../auth/widgets/auth_loading_widget.dart';
import '../domain/entities/profile_entity.dart';
import '../providers/profile_provider.dart';

class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _cityController;

  String? _gender;
  String? _language;
  String? _theme;

  bool _notifications = true;

  DateTime? _dob;

  bool _saving = false;

  static const List<String> _genders = [
    "Male",
    "Female",
    "Other",
    "Prefer not to say",
  ];

  static const List<String> _languages = ["English", "Hindi"];

  static const List<String> _themes = ["System", "Light", "Dark"];

  @override
  void initState() {
    super.initState();

    final profile = ref.read(profileProvider).value;
    final authUser = ref.read(authUserProvider);

    _nameController = TextEditingController(
      text: profile?.name ?? authUser?.name ?? "",
    );

    _bioController = TextEditingController(text: profile?.profile.bio ?? "");

    _cityController = TextEditingController(text: profile?.location.city ?? "");

    _gender = profile?.profile.gender;

    _language = profile?.preferences.language ?? "English";

    _theme = profile?.preferences.theme ?? "System";

    _notifications = profile?.preferences.notifications ?? true;

    if (profile?.profile.dob != null && profile!.profile.dob!.isNotEmpty) {
      _dob = DateTime.tryParse(profile.profile.dob!);
    }
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
      setState(() {
        _dob = picked;
      });
    }
  }

  Future<void> _save(ProfileEntity profile) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    final updated = profile.copyWith(
      name: _nameController.text.trim(),

      profile: profile.profile.copyWith(
        bio: _bioController.text.trim(),
        gender: _gender,
        dob: _dob?.toIso8601String(),
        location: _cityController.text.trim(), 
      ),

      location: profile.location.copyWith(city: _cityController.text.trim()),

      preferences: profile.preferences.copyWith(
        language: _language,
        theme: _theme,
        notifications: _notifications,
      ),
    );

    try {
      await ref.read(profileProvider.notifier).updateProfile(updated);

      if (!mounted) return;

      ref.read(authControllerProvider.notifier).markProfileComplete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile completed successfully")),
      );

      context.go(RoutePaths.home);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) {
      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      loading: () => const Scaffold(
        body: Center(child: AuthLoadingWidget(message: "Loading profile...")),
      ),

      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text("Complete Profile")),
        body: Center(child: Text(error.toString())),
      ),

      data: (profile) {
        if (profile == null) {
          return const Scaffold(body: Center(child: Text("Profile not found")));
        }

        return Scaffold(
          appBar: AppBar(title: const Text("Complete Profile")),

          body: SafeArea(
            child: Form(
              key: _formKey,

              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(20),

                    children: [
                      Card(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 55,
                                    backgroundImage:
                                        profile.picture != null &&
                                            profile.picture!.isNotEmpty
                                        ? NetworkImage(profile.picture!)
                                        : null,
                                    child:
                                        profile.picture == null ||
                                            profile.picture!.isEmpty
                                        ? const Icon(Icons.person, size: 55)
                                        : null,
                                  ),

                                  FloatingActionButton.small(
                                    heroTag: "profile_avatar",
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Profile photo upload will be available soon.",
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Icon(Icons.camera_alt),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              Text(
                                profile.email,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Card(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Personal Information",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),

                              const SizedBox(height: 20),

                              TextFormField(
                                controller: _nameController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: "Full Name",
                                  prefixIcon: Icon(Icons.person_outline),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Please enter your full name";
                                  }

                                  if (value.trim().length < 3) {
                                    return "Minimum 3 characters required";
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 18),

                              TextFormField(
                                controller: _bioController,
                                minLines: 3,
                                maxLines: 5,
                                maxLength: 250,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(250),
                                ],
                                decoration: const InputDecoration(
                                  labelText: "Bio",
                                  alignLabelWithHint: true,
                                  prefixIcon: Icon(Icons.description_outlined),
                                  border: OutlineInputBorder(),
                                ),
                              ),

                              const SizedBox(height: 18),

                              DropdownButtonFormField<String>(
                                initialValue: _gender,
                                decoration: const InputDecoration(
                                  labelText: "Gender",
                                  prefixIcon: Icon(Icons.people_outline),
                                  border: OutlineInputBorder(),
                                ),
                                items: _genders
                                    .map(
                                      (gender) => DropdownMenuItem(
                                        value: gender,
                                        child: Text(gender),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _gender = value;
                                  });
                                },
                              ),

                              const SizedBox(height: 18),

                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: _pickDate,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: "Date of Birth",
                                    prefixIcon: Icon(Icons.cake_outlined),
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Text(
                                    _dob == null
                                        ? "Select Date"
                                        : "${_dob!.day}/${_dob!.month}/${_dob!.year}",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Card(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Location",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),

                              const SizedBox(height: 20),

                              TextFormField(
                                controller: _cityController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: "City",
                                  prefixIcon: Icon(
                                    Icons.location_city_outlined,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Please enter your city";
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(Icons.my_location),
                                      title: const Text("Latitude"),
                                      subtitle: Text(
                                        profile.location.latitude
                                                ?.toStringAsFixed(6) ??
                                            "--",
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(Icons.explore),
                                      title: const Text("Longitude"),
                                      subtitle: Text(
                                        profile.location.longitude
                                                ?.toStringAsFixed(6) ??
                                            "--",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Card(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Preferences",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),

                              const SizedBox(height: 20),

                              DropdownButtonFormField<String>(
                                initialValue: _language,
                                decoration: const InputDecoration(
                                  labelText: "Language",
                                  prefixIcon: Icon(Icons.language),
                                  border: OutlineInputBorder(),
                                ),
                                items: _languages
                                    .map(
                                      (language) => DropdownMenuItem(
                                        value: language,
                                        child: Text(language),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _language = value;
                                  });
                                },
                              ),

                              const SizedBox(height: 18),

                              DropdownButtonFormField<String>(
                                initialValue: _theme,
                                decoration: const InputDecoration(
                                  labelText: "Theme",
                                  prefixIcon: Icon(Icons.palette_outlined),
                                  border: OutlineInputBorder(),
                                ),
                                items: _themes
                                    .map(
                                      (theme) => DropdownMenuItem(
                                        value: theme,
                                        child: Text(theme),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _theme = value;
                                  });
                                },
                              ),

                              const SizedBox(height: 18),

                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                value: _notifications,
                                title: const Text("Enable Notifications"),
                                subtitle: const Text(
                                  "Receive updates and travel alerts",
                                ),
                                secondary: const Icon(
                                  Icons.notifications_active,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _notifications = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text("Complete Profile"),
                          onPressed: _saving ? null : () => _save(profile),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),

                  if (_saving)
                    Container(
                      color: Colors.black45,
                      alignment: Alignment.center,
                      child: const Card(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 24,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),

                              SizedBox(height: 16),

                              Text(
                                "Completing your profile...",
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
