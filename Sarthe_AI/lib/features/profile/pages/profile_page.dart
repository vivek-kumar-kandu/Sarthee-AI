import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../auth/auth_provider.dart';
import '../domain/entities/profile_entity.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  Future<void> _refresh() async {
    await ref.read(profileProvider.notifier).refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final authUser = ref.watch(authUserProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("My Profile"),
        actions: [
          IconButton(
            tooltip: "Edit Profile",
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              context.push(RoutePaths.editProfile);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: profileAsync.when(
          loading: () => const _LoadingView(),
          error: (error, stack) => _ErrorView(
            message: error.toString(),
            onRetry: () {
              ref.read(profileProvider.notifier).loadProfile();
            },
          ),
          data: (profile) {
            if (profile == null) {
              return const _EmptyView();
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                _ProfileHeader(
                  profile: profile,
                  fallbackName: authUser?.name,
                  fallbackEmail: authUser?.email,
                ),

                const SizedBox(height: 24),

                _CompletionCard(profile),

                const SizedBox(height: 24),

                _SectionCard(
                  title: "Account",
                  icon: Icons.person_outline,
                  children: [
                    _InfoTile(
                      icon: Icons.badge_outlined,
                      title: "Name",
                      value: profile.name,
                    ),
                    _InfoTile(
                      icon: Icons.email_outlined,
                      title: "Email",
                      value: profile.email,
                    ),
                    _InfoTile(
                      icon: Icons.verified_user_outlined,
                      title: "Role",
                      value: profile.role,
                    ),
                    _InfoTile(
                      icon: Icons.circle,
                      title: "Status",
                      value: profile.isActive ? "Active" : "Inactive",
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _SectionCard(
                  title: "Personal Information",
                  icon: Icons.assignment_ind_outlined,
                  children: [
                    _InfoTile(
                      icon: Icons.cake_outlined,
                      title: "Date of Birth",
                      value: profile.profile.dob ?? "Not Set",
                    ),
                    _InfoTile(
                      icon: Icons.person_outline,
                      title: "Gender",
                      value: profile.profile.gender ?? "Not Set",
                    ),
                    _InfoTile(
                      icon: Icons.description_outlined,
                      title: "Bio",
                      value: profile.profile.bio ?? "No Bio",
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _SectionCard(
                  title: "Location",
                  icon: Icons.location_on_outlined,
                  children: [
                    _InfoTile(
                      icon: Icons.location_city_outlined,
                      title: "City",
                      value: profile.location.city ?? "Unknown",
                    ),
                    _InfoTile(
                      icon: Icons.my_location_outlined,
                      title: "Latitude",
                      value: profile.location.latitude?.toString() ?? "--",
                    ),
                    _InfoTile(
                      icon: Icons.explore_outlined,
                      title: "Longitude",
                      value: profile.location.longitude?.toString() ?? "--",
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _SectionCard(
                  title: "Preferences",
                  icon: Icons.tune_outlined,
                  children: [
                    _InfoTile(
                      icon: Icons.language_outlined,
                      title: "Language",
                      value: profile.preferences.language ?? "Default",
                    ),
                    _InfoTile(
                      icon: Icons.palette_outlined,
                      title: "Theme",
                      value: profile.preferences.theme ?? "System",
                    ),
                    _InfoTile(
                      icon: Icons.notifications_active_outlined,
                      title: "Notifications",
                      value: (profile.preferences.notifications ?? false)
                          ? "Enabled"
                          : "Disabled",
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _SectionCard(
                  title: "Account Activity",
                  icon: Icons.history,
                  children: [
                    _InfoTile(
                      icon: Icons.calendar_today_outlined,
                      title: "Created",
                      value: _formatDate(profile.createdAt),
                    ),
                    _InfoTile(
                      icon: Icons.update_outlined,
                      title: "Last Updated",
                      value: _formatDate(profile.updatedAt),
                    ),
                    _InfoTile(
                      icon: Icons.login_outlined,
                      title: "Last Login",
                      value: profile.lastLoginAt == null
                          ? "Never"
                          : _formatDate(profile.lastLoginAt!),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: () {
                    context.push(RoutePaths.editProfile);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Profile"),
                ),

                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    this.fallbackName,
    this.fallbackEmail,
  });

  final ProfileEntity profile;
  final String? fallbackName;
  final String? fallbackEmail;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundImage:
                  profile.picture != null && profile.picture!.isNotEmpty
                  ? NetworkImage(profile.picture!)
                  : null,
              child: profile.picture == null || profile.picture!.isEmpty
                  ? const Icon(Icons.person, size: 42)
                  : null,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name.isNotEmpty
                        ? profile.name
                        : fallbackName ?? "Traveler",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    profile.email.isNotEmpty
                        ? profile.email
                        : fallbackEmail ?? "Email unavailable",
                  ),
                  const SizedBox(height: 10),
                  Chip(
                    avatar: const Icon(Icons.verified, size: 18),
                    label: Text(profile.role),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard(this.profile);

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    int completed = 0;
    const total = 8;

    if (profile.name.isNotEmpty) completed++;
    if (profile.email.isNotEmpty) completed++;
    if ((profile.profile.bio ?? "").isNotEmpty) completed++;
    if ((profile.profile.gender ?? "").isNotEmpty) completed++;
    if ((profile.profile.dob ?? "").isNotEmpty) completed++;
    if ((profile.location.city ?? "").isNotEmpty) completed++;
    if ((profile.preferences.language ?? "").isNotEmpty) completed++;
    if ((profile.preferences.theme ?? "").isNotEmpty) completed++;

    final progress = completed / total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Profile Completion",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 12),
            Text("${(progress * 100).round()}% Complete"),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(radius: 20, child: Icon(icon, size: 20)),
      title: Text(title),
      subtitle: Text(value, maxLines: 3, overflow: TextOverflow.ellipsis),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: List.generate(
        6,
        (index) => Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          child: Container(
            height: index == 0 ? 120 : 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Icon(
          Icons.error_outline,
          size: 72,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 20),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
          ),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Icon(
          Icons.person_outline,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            "Profile not found",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Complete your profile to personalize your experience.",
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: FilledButton.icon(
            onPressed: () {
              context.push(RoutePaths.editProfile);
            },
            icon: const Icon(Icons.edit),
            label: const Text("Create Profile"),
          ),
        ),
      ],
    );
  }
}
