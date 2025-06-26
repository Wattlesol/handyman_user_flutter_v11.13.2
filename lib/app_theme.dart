import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/font_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';

// Custom theme extension for brand colors
@immutable
class BrandColors extends ThemeExtension<BrandColors> {
  const BrandColors({
    required this.brandYellow,
    required this.brandRed,
    required this.brandGreen,
    required this.brandBlue,
  });

  final Color brandYellow;
  final Color brandRed;
  final Color brandGreen;
  final Color brandBlue;

  @override
  BrandColors copyWith({
    Color? brandYellow,
    Color? brandRed,
    Color? brandGreen,
    Color? brandBlue,
  }) {
    return BrandColors(
      brandYellow: brandYellow ?? this.brandYellow,
      brandRed: brandRed ?? this.brandRed,
      brandGreen: brandGreen ?? this.brandGreen,
      brandBlue: brandBlue ?? this.brandBlue,
    );
  }

  @override
  BrandColors lerp(BrandColors? other, double t) {
    if (other is! BrandColors) {
      return this;
    }
    return BrandColors(
      brandYellow: Color.lerp(brandYellow, other.brandYellow, t)!,
      brandRed: Color.lerp(brandRed, other.brandRed, t)!,
      brandGreen: Color.lerp(brandGreen, other.brandGreen, t)!,
      brandBlue: Color.lerp(brandBlue, other.brandBlue, t)!,
    );
  }

  // Light theme colors
  static const light = BrandColors(
    brandYellow: brandYellowLight,
    brandRed: brandRedLight,
    brandGreen: brandGreenLight,
    brandBlue: brandBlueLight,
  );

  // Dark theme colors
  static const dark = BrandColors(
    brandYellow: brandYellowDark,
    brandRed: brandRedDark,
    brandGreen: brandGreenDark,
    brandBlue: brandBlueDark,
  );
}

class AppTheme {
  //
  AppTheme._();

  static ThemeData lightTheme({Color? color}) => ThemeData(
        useMaterial3: true,
        primarySwatch: createMaterialColor(color ?? primaryColor),
        primaryColor: color ?? primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: color ?? primaryColor,
          outlineVariant: borderColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: FontUtils.getMainFontFamily(),
        bottomNavigationBarTheme:
            BottomNavigationBarThemeData(backgroundColor: Colors.white),
        iconTheme: IconThemeData(color: appTextSecondaryColor),
        listTileTheme: ListTileThemeData(
            iconColor: borderColor,
            titleTextStyle: boldTextStyle(color: black),
            subtitleTextStyle: secondaryTextStyle()),
        textTheme: FontUtils.getTextTheme(isDark: false),
        unselectedWidgetColor: Colors.black,
        dividerColor: borderColor,
        bottomSheetTheme: BottomSheetThemeData(
          shape: RoundedRectangleBorder(
              borderRadius:
                  radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
          backgroundColor: Colors.white,
        ),
        cardColor: cardColor,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: color ?? primaryColor),
        appBarTheme: AppBarTheme(
            backgroundColor: color ?? primaryColor,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: secondaryTextStyle(size: 22, color: white),
            systemOverlayStyle: SystemUiOverlayStyle(
                statusBarIconBrightness: Brightness.light)),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: dialogShape(),
        ),
        navigationBarTheme: NavigationBarThemeData(
            labelTextStyle:
                WidgetStateProperty.all(primaryTextStyle(size: 10))),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        extensions: <ThemeExtension<dynamic>>[
          BrandColors.light,
        ],
      );

  static ThemeData darkTheme({Color? color}) => ThemeData(
        useMaterial3: true,
        primarySwatch: createMaterialColor(color ?? primaryColor),
        primaryColor: color ?? primaryColor,
        colorScheme: ColorScheme.fromSeed(
            seedColor: color ?? primaryColor,
            outlineVariant: borderColor,
            brightness: Brightness.dark,
            surface: scaffoldColorDark,
            onSurface: Colors.white),
        appBarTheme: AppBarTheme(
          backgroundColor: color ?? primaryColor,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: secondaryTextStyle(size: 22, color: white),
          systemOverlayStyle:
              SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
        ),
        scaffoldBackgroundColor: scaffoldColorDark,
        fontFamily: FontUtils.getMainFontFamily(),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: scaffoldSecondaryDark),
        iconTheme: IconThemeData(color: Colors.white),
        listTileTheme: ListTileThemeData(
            iconColor: Colors.white,
            titleTextStyle: boldTextStyle(color: white),
            subtitleTextStyle: secondaryTextStyle()),
        textTheme: FontUtils.getTextTheme(isDark: true),
        unselectedWidgetColor: Colors.white60,
        bottomSheetTheme: BottomSheetThemeData(
          shape: RoundedRectangleBorder(
              borderRadius:
                  radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
          backgroundColor: scaffoldSecondaryDark,
        ),
        dividerColor: dividerDarkColor,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: color ?? primaryColor),
        cardColor: scaffoldSecondaryDark,
        dialogTheme: DialogThemeData(
          backgroundColor: scaffoldSecondaryDark,
          surfaceTintColor: Colors.transparent,
          shape: dialogShape(),
        ),
        navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.all(
                primaryTextStyle(size: 10, color: Colors.white))),
        extensions: <ThemeExtension<dynamic>>[
          BrandColors.dark,
        ],
      ).copyWith(
        pageTransitionsTheme: PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );
}

// Extension to easily access brand colors from BuildContext
extension BrandColorsExtension on BuildContext {
  BrandColors get brandColors => Theme.of(this).extension<BrandColors>()!;
}
