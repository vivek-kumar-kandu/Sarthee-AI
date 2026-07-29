import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Central Material 3 theme configuration for Sarthee AI.
///
/// All global component styling should be configured here whenever
/// possible instead of repeatedly styling widgets inside feature screens.
abstract final class AppTheme {
  // ============================================================
  // LIGHT COLOR SCHEME
  // ============================================================

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,

    primary: AppColors.lightPrimary,
    onPrimary: AppColors.lightOnPrimary,
    primaryContainer: AppColors.lightPrimaryContainer,
    onPrimaryContainer: AppColors.lightOnPrimaryContainer,

    secondary: AppColors.lightSecondary,
    onSecondary: AppColors.lightOnSecondary,
    secondaryContainer: AppColors.lightSecondaryContainer,
    onSecondaryContainer: AppColors.lightOnSecondaryContainer,

    tertiary: AppColors.lightTertiary,
    onTertiary: AppColors.lightOnTertiary,
    tertiaryContainer: AppColors.lightTertiaryContainer,
    onTertiaryContainer: AppColors.lightOnTertiaryContainer,

    error: AppColors.error,
    onError: AppColors.white,
    errorContainer: AppColors.errorLight,
    onErrorContainer: AppColors.error,

    surface: AppColors.lightSurface,
    onSurface: AppColors.lightOnSurface,

    surfaceContainerLowest: AppColors.lightSurfaceContainerLowest,
    surfaceContainerLow: AppColors.lightSurfaceContainerLow,
    surfaceContainer: AppColors.lightSurfaceContainer,
    surfaceContainerHigh: AppColors.lightSurfaceContainerHigh,
    surfaceContainerHighest: AppColors.lightSurfaceContainerHighest,

    onSurfaceVariant: AppColors.lightOnSurfaceVariant,

    outline: AppColors.lightOutline,
    outlineVariant: AppColors.lightOutlineVariant,

    shadow: AppColors.black,
    scrim: AppColors.black,

    inverseSurface: AppColors.lightInverseSurface,
    onInverseSurface: AppColors.lightOnInverseSurface,
    inversePrimary: AppColors.lightInversePrimary,

    surfaceTint: AppColors.lightPrimary,
  );

  // ============================================================
  // DARK COLOR SCHEME
  // ============================================================

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,

    primary: AppColors.darkPrimary,
    onPrimary: AppColors.darkOnPrimary,
    primaryContainer: AppColors.darkPrimaryContainer,
    onPrimaryContainer: AppColors.darkOnPrimaryContainer,

    secondary: AppColors.darkSecondary,
    onSecondary: AppColors.darkOnSecondary,
    secondaryContainer: AppColors.darkSecondaryContainer,
    onSecondaryContainer: AppColors.darkOnSecondaryContainer,

    tertiary: AppColors.darkTertiary,
    onTertiary: AppColors.darkOnTertiary,
    tertiaryContainer: AppColors.darkTertiaryContainer,
    onTertiaryContainer: AppColors.darkOnTertiaryContainer,

    error: AppColors.errorDark,
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: AppColors.errorLight,

    surface: AppColors.darkSurface,
    onSurface: AppColors.darkOnSurface,

    surfaceContainerLowest: AppColors.darkSurfaceContainerLowest,
    surfaceContainerLow: AppColors.darkSurfaceContainerLow,
    surfaceContainer: AppColors.darkSurfaceContainer,
    surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
    surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,

    onSurfaceVariant: AppColors.darkOnSurfaceVariant,

    outline: AppColors.darkOutline,
    outlineVariant: AppColors.darkOutlineVariant,

    shadow: AppColors.black,
    scrim: AppColors.black,

    inverseSurface: AppColors.darkInverseSurface,
    onInverseSurface: AppColors.darkOnInverseSurface,
    inversePrimary: AppColors.darkInversePrimary,

    surfaceTint: AppColors.darkPrimary,
  );

  // ============================================================
  // PUBLIC THEMES
  // ============================================================

  static ThemeData get lightTheme =>
      _buildTheme(colorScheme: _lightColorScheme, brightness: Brightness.light);

  static ThemeData get darkTheme =>
      _buildTheme(colorScheme: _darkColorScheme, brightness: Brightness.dark);

  // ============================================================
  // THEME BUILDER
  // ============================================================

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Brightness brightness,
  }) {
    final bool isDark = brightness == Brightness.dark;

    final textTheme = AppTextStyles.buildTextTheme(colorScheme);

    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      fontFamily: AppTextStyles.fontFamily,

      scaffoldBackgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,

      canvasColor: colorScheme.surface,

      dividerColor: isDark ? AppColors.darkDivider : AppColors.lightDivider,

      disabledColor: isDark
          ? AppColors.darkTextDisabled
          : AppColors.lightTextDisabled,

      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,

      splashFactory: InkSparkle.splashFactory,
    );

    return baseTheme.copyWith(
      // ========================================================
      // APP BAR
      // ========================================================
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: AppSpacing.appBarHeight,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: AppTextStyles.semiBold,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: AppSpacing.iconMD,
        ),
        actionsIconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: AppSpacing.iconMD,
        ),
      ),

      // ========================================================
      // CARDS
      // ========================================================
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shadowColor: isDark ? AppColors.darkShadow : AppColors.lightShadow,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLG,
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: AppSpacing.borderWidth,
          ),
        ),
      ),

      // ========================================================
      // ELEVATED BUTTON
      // ========================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(
            AppSpacing.minimumTouchTarget,
            AppSpacing.buttonHeight,
          ),
          padding: AppSpacing.buttonPadding,
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.onSurface.withValues(
            alpha: 0.12,
          ),
          disabledForegroundColor: colorScheme.onSurface.withValues(
            alpha: 0.38,
          ),
          textStyle: AppTextStyles.buttonLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
      ),

      // ========================================================
      // FILLED BUTTON
      // ========================================================
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            AppSpacing.minimumTouchTarget,
            AppSpacing.buttonHeight,
          ),
          padding: AppSpacing.buttonPadding,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: AppTextStyles.buttonLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
      ),

      // ========================================================
      // OUTLINED BUTTON
      // ========================================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            AppSpacing.minimumTouchTarget,
            AppSpacing.buttonHeight,
          ),
          padding: AppSpacing.buttonPadding,
          foregroundColor: colorScheme.primary,
          side: BorderSide(
            color: colorScheme.outline,
            width: AppSpacing.borderWidth,
          ),
          textStyle: AppTextStyles.buttonLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
      ),

      // ========================================================
      // TEXT BUTTON
      // ========================================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(
            AppSpacing.minimumTouchTarget,
            AppSpacing.minimumTouchTarget,
          ),
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space16,
            vertical: AppSpacing.space12,
          ),
          textStyle: AppTextStyles.buttonMedium,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMD,
          ),
        ),
      ),

      // ========================================================
      // ICON BUTTON
      // ========================================================
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(AppSpacing.minimumTouchTarget),
          foregroundColor: colorScheme.onSurfaceVariant,
          disabledForegroundColor: colorScheme.onSurface.withValues(
            alpha: 0.38,
          ),
        ),
      ),

      // ========================================================
      // FLOATING ACTION BUTTON
      // ========================================================
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        highlightElevation: 4,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLG),
      ),

      // ========================================================
      // INPUT / TEXT FIELD
      // ========================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors.darkSurfaceContainer
            : AppColors.lightSurfaceContainerLow,

        contentPadding: AppSpacing.inputContentPadding,

        hintStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
        ),

        labelStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),

        floatingLabelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: AppTextStyles.medium,
        ),

        helperStyle: AppTextStyles.helperText.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),

        errorStyle: AppTextStyles.errorText.copyWith(color: colorScheme.error),

        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant,
            width: AppSpacing.borderWidth,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: AppSpacing.focusedBorderWidth,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: AppSpacing.borderWidth,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: AppSpacing.focusedBorderWidth,
          ),
        ),

        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),

      // ========================================================
      // BOTTOM NAVIGATION / MATERIAL 3 NAVIGATION BAR
      // ========================================================
      navigationBarTheme: NavigationBarThemeData(
        height: AppSpacing.bottomNavigationHeight,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.secondaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusFull,
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: colorScheme.onSecondaryContainer,
              size: AppSpacing.navigationIconSize,
            );
          }

          return IconThemeData(
            color: colorScheme.onSurfaceVariant,
            size: AppSpacing.navigationIconSize,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.navigationLabelSelected.copyWith(
              color: colorScheme.onSurface,
            );
          }

          return AppTextStyles.navigationLabel.copyWith(
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),

      // ========================================================
      // NAVIGATION RAIL
      // ========================================================
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        useIndicator: true,
        minWidth: AppSpacing.navigationRailWidth,
        minExtendedWidth: AppSpacing.extendedNavigationRailWidth,
        selectedIconTheme: IconThemeData(
          color: colorScheme.onSecondaryContainer,
        ),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: AppTextStyles.navigationLabelSelected.copyWith(
          color: colorScheme.onSurface,
        ),
        unselectedLabelTextStyle: AppTextStyles.navigationLabel.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // ========================================================
      // DRAWER
      // ========================================================
      drawerTheme: DrawerThemeData(
        width: AppSpacing.drawerWidth,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(AppSpacing.radiusXL),
            bottomRight: Radius.circular(AppSpacing.radiusXL),
          ),
        ),
      ),

      // ========================================================
      // LIST TILE
      // ========================================================
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space4,
        ),
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
        titleTextStyle: textTheme.bodyLarge?.copyWith(
          fontWeight: AppTextStyles.medium,
        ),
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMD),
      ),

      // ========================================================
      // CHIPS
      // ========================================================
      chipTheme: ChipThemeData(
        elevation: 0,
        pressElevation: 0,
        backgroundColor: colorScheme.surfaceContainerLow,
        selectedColor: colorScheme.secondaryContainer,
        disabledColor: colorScheme.onSurface.withValues(alpha: 0.08),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: colorScheme.onSurface,
        ),
        secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(
          color: colorScheme.onSecondaryContainer,
        ),
        side: BorderSide(color: colorScheme.outlineVariant),
        padding: AppSpacing.chipPadding,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusFull,
        ),
      ),

      // ========================================================
      // DIALOG
      // ========================================================
      dialogTheme: DialogThemeData(
        elevation: 6,
        backgroundColor: colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.mediumShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.dialogRadius),
        ),
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: colorScheme.onSurface,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // ========================================================
      // BOTTOM SHEET
      // ========================================================
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0,
        modalElevation: 4,
        backgroundColor: colorScheme.surface,
        modalBackgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        dragHandleSize: const Size(
          AppSpacing.bottomSheetHandleWidth,
          AppSpacing.bottomSheetHandleHeight,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.bottomSheetRadius),
          ),
        ),
      ),

      // ========================================================
      // SNACKBAR
      // ========================================================
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        backgroundColor: colorScheme.inverseSurface,
        actionTextColor: colorScheme.inversePrimary,
        disabledActionTextColor: colorScheme.onInverseSurface.withValues(
          alpha: 0.5,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        insetPadding: AppSpacing.snackBarMargin,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.snackBarRadius),
        ),
      ),

      // ========================================================
      // TOOLTIP
      // ========================================================
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: AppSpacing.borderRadiusSM,
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        padding: AppSpacing.paddingSM,
        waitDuration: const Duration(milliseconds: 500),
      ),

      // ========================================================
      // DIVIDER
      // ========================================================
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: AppSpacing.dividerThickness,
        space: AppSpacing.space16,
      ),

      // ========================================================
      // CHECKBOX
      // ========================================================
      checkboxTheme: CheckboxThemeData(
        visualDensity: VisualDensity.standard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
        ),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }

          return Colors.transparent;
        }),
        checkColor: WidgetStatePropertyAll(colorScheme.onPrimary),
        side: BorderSide(
          color: colorScheme.outline,
          width: AppSpacing.borderWidth,
        ),
      ),

      // ========================================================
      // RADIO
      // ========================================================
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }

          return colorScheme.onSurfaceVariant;
        }),
      ),

      // ========================================================
      // SWITCH
      // ========================================================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }

          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }

          return colorScheme.surfaceContainerHighest;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }

          return colorScheme.outline;
        }),
      ),

      // ========================================================
      // PROGRESS INDICATORS
      // ========================================================
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),

      // ========================================================
      // TAB BAR
      // ========================================================
      tabBarTheme: TabBarThemeData(
        dividerColor: Colors.transparent,
        indicatorColor: colorScheme.primary,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: AppTextStyles.labelLarge.copyWith(
          fontWeight: AppTextStyles.semiBold,
        ),
        unselectedLabelStyle: AppTextStyles.labelLarge,
      ),

      // ========================================================
      // POPUP MENU
      // ========================================================
      popupMenuTheme: PopupMenuThemeData(
        elevation: 4,
        color: colorScheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        textStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMD),
      ),

      // ========================================================
      // DROPDOWN MENU
      // ========================================================
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodyLarge,
        inputDecorationTheme: baseTheme.inputDecorationTheme,
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(colorScheme.surfaceContainer),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMD),
          ),
        ),
      ),

      // ========================================================
      // SEARCH BAR
      // ========================================================
      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(
          colorScheme.surfaceContainerLow,
        ),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        textStyle: WidgetStatePropertyAll(textTheme.bodyLarge),
        hintStyle: WidgetStatePropertyAll(
          textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusFull),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: AppSpacing.space16),
        ),
      ),

      // ========================================================
      // SEARCH VIEW
      // ========================================================
      searchViewTheme: SearchViewThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        headerTextStyle: textTheme.bodyLarge,
        headerHintStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        dividerColor: colorScheme.outlineVariant,
      ),

      // ========================================================
      // BADGE
      // ========================================================
      badgeTheme: BadgeThemeData(
        backgroundColor: colorScheme.error,
        textColor: colorScheme.onError,
        textStyle: AppTextStyles.labelSmall,
      ),

      // ========================================================
      // SEGMENTED BUTTON
      // ========================================================
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(AppTextStyles.labelLarge),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.onSecondaryContainer;
            }

            return colorScheme.onSurface;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.secondaryContainer;
            }

            return Colors.transparent;
          }),
          side: WidgetStatePropertyAll(
            BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
      ),

      // ========================================================
      // MENU
      // ========================================================
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(colorScheme.surfaceContainer),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(4),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMD),
          ),
        ),
      ),

      // ========================================================
      // PAGE TRANSITIONS
      // ========================================================
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  AppTheme._();
}
