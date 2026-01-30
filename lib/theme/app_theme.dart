import 'package:flutter/material.dart';

// 1. Define your custom color properties as a ThemeExtension
@immutable
class AppColorExtension extends ThemeExtension<AppColorExtension> {
  const AppColorExtension({
    required this.container,
    required this.card,
    required this.textHigh,
    required this.textMuted,
  });

  final Color? container;
  final Color? card;
  final Color? textHigh;
  final Color? textMuted;

  @override
  AppColorExtension copyWith({
    Color? container,
    Color? card,
    Color? textHigh,
    Color? textMuted,
  }) {
    return AppColorExtension(
      container: container ?? this.container,
      card: card ?? this.card,
      textHigh: textHigh ?? this.textHigh,
      textMuted: textMuted ?? this.textMuted,
    );
  }

  @override
  AppColorExtension lerp(ThemeExtension<AppColorExtension>? other, double t) {
    if (other is! AppColorExtension) {
      return this;
    }
    return AppColorExtension(
      container: Color.lerp(container, other.container, t),
      card: Color.lerp(card, other.card, t),
      textHigh: Color.lerp(textHigh, other.textHigh, t),
      textMuted: Color.lerp(textMuted, other.textMuted, t),
    );
  }
}

// 2. Define your color palettes
class AppColors {
  // Light Theme Colors
  static const Color background = Color(0xFFD8EFD3);
  static const Color container = Color(0xFFCAE8BD);
  static const Color card = Color(0xFFB3D8A8);
  static const Color textHigh = Color(0xFF196519);
  static const Color text = Color(0xFF0D3619);
  static const Color textMuted = Color(0xFFA9A9A9);
  static const Color accent = Color(0xFF80AF81);

  // Dark Theme Colors
  static const Color dbackground = Color(0xFF1F4529);
  static const Color dcontainer = Color(0xFF255F38);
  static const Color dcard = Color(0xFF357943);
  static const Color dtextHigh = Color(0xFF63B467);
  static const Color dtext = Color(0xFFECECEC);
  static const Color dtextMuted = Color(0xFFA9A9A9);
  static const Color daccent = Color(0xFF609755);
}

// 3. Create your ThemeData objects
final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    // Map your colors to the ColorScheme properties
    brightness: Brightness.light,
    primary: AppColors.accent,
    onPrimary: AppColors.text,
    surface: AppColors.background, // Often same as background
    onSurface: AppColors.text,
    error: Colors.red,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: AppColors.background,
  extensions: const <ThemeExtension<dynamic>>[
    AppColorExtension(
      container: AppColors.container,
      card: AppColors.card,
      textHigh: AppColors.textHigh,
      textMuted: AppColors.textMuted,
    ),
  ],
  // ADD THIS SECTION
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.container,
    indicatorColor: AppColors.accent,
    iconTheme: WidgetStateProperty.resolveWith((states) {
      // If the icon is in the "selected" state, apply this color.
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: AppColors.dbackground);
      } else {
        // Otherwise, apply this color for the "unselected" state.
        return IconThemeData(color: AppColors.dtextMuted);
      }
    }),
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    // Map your dark colors
    brightness: Brightness.dark,
    primary: AppColors.daccent,
    onPrimary: AppColors.dtext,
    surface: AppColors.dbackground,
    onSurface: AppColors.dtext,
    error: Colors.red,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: AppColors.dbackground,
  extensions: const <ThemeExtension<dynamic>>[
    AppColorExtension(
      container: AppColors.dcontainer,
      card: AppColors.dcard,
      textHigh: AppColors.dtextHigh,
      textMuted: AppColors.dtextMuted,
    ),
  ],
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.dcontainer,
    indicatorColor: AppColors.daccent,

    // This is where you control the ICON color.
    iconTheme: WidgetStateProperty.resolveWith((states) {
      // If the icon is in the "selected" state, apply this color.
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: AppColors.background);
      } else {
        // Otherwise, apply this color for the "unselected" state.
        return IconThemeData(color: AppColors.textMuted);
      }
    }),
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
  ),
);
