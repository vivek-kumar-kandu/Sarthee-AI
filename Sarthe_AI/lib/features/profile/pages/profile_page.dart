import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../../core/responsive/app_responsive.dart';
import '../../auth/auth_provider.dart';
import '../../auth/widgets/auth_loading_widget.dart';
import '../domain/entities/profile_entity.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_completion_banner.dart';
import '../widgets/profile_insight_card.dart';
import '../widgets/profile_passport_card.dart';
import '../widgets/profile_summary_widget.dart';

/// Main My Profile Screen featuring Travel Passport Card, Completion Banner, & Menu Shortcuts.
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

  Future<void> _showLogoutDialog() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
          title: const Text("Logout"),
          content: const Text(
            "Are you sure you want to logout from Sarthee AI?",
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
    if (shouldLogout == true) {
      try {
        await ref.read(authControllerProvider.notifier).logout();
        if (!mounted) return;
        context.go(RoutePaths.login);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Logout failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final authUser = ref.watch(authUserProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Profile",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Edit Profile",
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF475569)),
            onPressed: () {
              context.push(RoutePaths.editProfile);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFF4F46E5),
        child: profileAsync.when(
          loading: () => const AuthLoadingWidget(),
          error: (error, stack) => _ErrorView(
            message: error.toString(),
            onRetry: () {
              ref.read(profileProvider.notifier).loadProfile(forceRefresh: true);
            },
          ),
          data: (profile) {
            final effectiveProfile = profile ??
                ProfileEntity(
                  id: 'temp',
                  firebaseUid: authUser?.uid ?? 'temp',
                  email: authUser?.email ?? '',
                  name: authUser?.name ?? 'Traveler',
                  picture: null,
                  role: 'user',
                  profile: const UserProfile(),
                  location: const UserLocation(city: 'India'),
                  preferences: const UserPreferences(language: 'English'),
                  isActive: true,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  lastLoginAt: DateTime.now(),
                );

            return SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: AppResponsive.screenPadding(context),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // 1. Travel Passport Header Card
                        ProfilePassportCard(
                          profile: effectiveProfile,
                          onEditPressed: () {
                            context.push(RoutePaths.editProfile);
                          },
                        ),

                        const SizedBox(height: 16),

                        // 2. Profile Completion Banner (if < 100%)
                        ProfileCompletionBanner(
                          profile: effectiveProfile,
                          onCompletePressed: () {
                            context.push(RoutePaths.completeProfile);
                          },
                        ),

                        const SizedBox(height: 12),

                        // 3. Profile Context Insight Card (Actionable tips)
                        ProfileInsightCard(
                          profile: effectiveProfile,
                          onActionPressed: () {
                            context.push(RoutePaths.completeProfile);
                          },
                        ),

                        const SizedBox(height: 12),

                        // 4. Travel Persona & Preference Summary
                        ProfileSummaryWidget(
                          profile: effectiveProfile,
                          onEditPressed: () {
                            context.push(RoutePaths.completeProfile);
                          },
                        ),

                        // 5. Account Shortcuts Section
                        _buildSectionTitle(theme, 'Account Shortcuts'),
                        const SizedBox(height: 10),
                        _buildMenuTile(
                          icon: Icons.stars_rounded,
                          title: 'Complete Travel Persona',
                          subtitle: 'Travel interests, pace, diet & budget tier',
                          iconColor: const Color(0xFF0D9488),
                          onTap: () => context.push(RoutePaths.completeProfile),
                        ),
                        _buildMenuTile(
                          icon: Icons.person_outline_rounded,
                          title: 'Edit Personal Profile',
                          subtitle: 'Update name, bio, and location',
                          onTap: () => context.push(RoutePaths.editProfile),
                        ),
                        _buildMenuTile(
                          icon: Icons.lock_outline_rounded,
                          title: 'Security & Password',
                          subtitle: 'Manage authentication settings',
                          onTap: () {},
                        ),
                        _buildMenuTile(
                          icon: Icons.logout_rounded,
                          title: 'Logout',
                          subtitle: 'Sign out from Sarthee AI',
                          iconColor: const Color(0xFFDC2626),
                          textColor: const Color(0xFFDC2626),
                          onTap: _showLogoutDialog,
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        color: const Color(0xFF1E293B),
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF475569),
    Color textColor = const Color(0xFF0F172A),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: Icon(icon, color: iconColor),
          title: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF94A3B8),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Color(0xFFDC2626),
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load profile',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
