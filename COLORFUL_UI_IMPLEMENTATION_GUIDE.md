# Colorful UI Implementation Guide

This document outlines all the changes made to transform the app into a colorful, vibrant interface using the Kangoo brand colors.

## 1. Brand Colors Setup

### File: `lib/utils/colors.dart`

Add these brand color constants:

```dart
// Brand Colors - Light Theme
const brandYellowLight = Color(0xFFF0B521);
const brandRedLight = Color(0xFFEF5535);
const brandGreenLight = Color(0xFF2DB665);
const brandBlueLight = Color(0xFF4A75FB);

// Brand Colors - Dark Theme
const brandYellowDark = Color(0xFF8D6710);
const brandRedDark = Color(0xFF9B1F0B);
const brandGreenDark = Color(0xFF005F2D);
const brandBlueDark = Color(0xFF004CB2);
```

Update status colors to use brand colors:

```dart
//Status Color - Updated to use brand colors
const pending = brandRedLight;
const accept = brandGreenLight;
const on_going = brandYellowLight;
const in_progress = brandBlueLight;
const hold = brandYellowLight;
const cancelled = brandRedLight;
const rejected = brandRedDark;
const failed = brandRedLight;
const completed = brandGreenLight;
const defaultStatus = brandGreenLight;
const pendingApprovalColor = brandBlueDark;
const waiting = brandBlueLight;

const add_booking = brandRedLight;
const assigned_booking = brandYellowLight;
const transfer_booking = brandGreenLight;
const update_booking_status = brandGreenLight;
const cancel_booking = brandRedLight;
const payment_message_status = brandYellowLight;
const defaultActivityStatus = brandGreenLight;
```

## 2. Theme Extension System

### File: `lib/app_theme.dart`

Add theme extension for brand colors:

```dart
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

// Extension to easily access brand colors from BuildContext
extension BrandColorsExtension on BuildContext {
  BrandColors get brandColors => Theme.of(this).extension<BrandColors>()!;
}
```

Update light theme to include brand colors:

```dart
static ThemeData lightTheme({Color? color}) => ThemeData(
  // ... existing theme properties ...
  extensions: <ThemeExtension<dynamic>>[
    BrandColors.light,
  ],
);
```

Update dark theme to include brand colors:

```dart
static ThemeData darkTheme({Color? color}) => ThemeData(
  // ... existing theme properties ...
  extensions: <ThemeExtension<dynamic>>[
    BrandColors.dark,
  ],
);
```

## 3. Font Configuration

### File: `pubspec.yaml`

Add Gluten font family:

```yaml
fonts:
  - family: Alexandria
    fonts:
      - asset: assets/fonts/Alexandria-Regular.ttf
        weight: 400
      - asset: assets/fonts/Alexandria-Bold.ttf
        weight: 700
      - asset: assets/fonts/Alexandria-SemiBold.ttf
        weight: 600
      - asset: assets/fonts/Alexandria-Medium.ttf
        weight: 500
  - family: Gluten
    fonts:
      - asset: assets/fonts/Gluten-Regular.ttf
        weight: 400
      - asset: assets/fonts/Gluten-Medium.ttf
        weight: 500
      - asset: assets/fonts/Gluten-SemiBold.ttf
        weight: 600
      - asset: assets/fonts/Gluten-Bold.ttf
        weight: 700
```

### Font Files Required:

Download and add these font files to `assets/fonts/`:

- Gluten-Regular.ttf
- Gluten-Medium.ttf
- Gluten-SemiBold.ttf
- Gluten-Bold.ttf

## 4. Sign-In Screen Updates

### File: `lib/screens/auth/sign_in_screen.dart`

Add import:

```dart
import 'package:booking_system_flutter/app_theme.dart';
```

Update top widget with colorful welcome text:

```dart
Widget _buildTopWidget() {
  return Container(
    child: Column(
      children: [
        // Colorful Kangoo Logo (use PNG asset)
        Container(
          height: 120,
          child: Image.asset(logoType), // or your logo asset
        ),
        24.height,
        // Colorful Welcome Text
        Text(
          "Welcome!",
          style: boldTextStyle(
            size: 32,
            color: context.brandColors.brandBlue,
            fontFamily: 'Gluten',
          ),
        ).center(),
        16.height,
        Text(
          language.lblLoginSubTitle,
          style: primaryTextStyle(
            size: 16,
            color: appTextSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ).center().paddingSymmetric(horizontal: 32),
        32.height,
      ],
    ),
  );
}
```

Update input fields with colorful styling:

```dart
// Email Field
AppTextField(
  textFieldType: TextFieldType.EMAIL_ENHANCED,
  controller: emailCont,
  focus: emailFocus,
  nextFocus: passwordFocus,
  errorThisFieldRequired: language.requiredText,
  decoration: inputDecoration(
    context,
    labelText: language.hintEmailTxt,
  ).copyWith(
    labelStyle: primaryTextStyle(color: context.brandColors.brandGreen),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: context.brandColors.brandGreen, width: 2),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: context.brandColors.brandGreen, width: 2),
    ),
  ),
  suffix: ic_message.iconImage(size: 10, color: context.brandColors.brandGreen).paddingAll(14),
  autoFillHints: [AutofillHints.email],
),

// Password Field
AppTextField(
  textFieldType: TextFieldType.PASSWORD,
  controller: passwordCont,
  focus: passwordFocus,
  obscureText: true,
  suffixPasswordVisibleWidget: ic_show.iconImage(size: 10, color: context.brandColors.brandGreen).paddingAll(14),
  suffixPasswordInvisibleWidget: ic_hide.iconImage(size: 10, color: context.brandColors.brandGreen).paddingAll(14),
  decoration: inputDecoration(
    context,
    labelText: language.hintPasswordTxt,
  ).copyWith(
    labelStyle: primaryTextStyle(color: context.brandColors.brandGreen),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: context.brandColors.brandGreen, width: 2),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: context.brandColors.brandGreen, width: 2),
    ),
  ),
  // ... other properties
),
```

Update checkbox and buttons:

```dart
// Remember Me Checkbox
RoundedCheckBox(
  borderColor: context.brandColors.brandGreen,
  checkedColor: context.brandColors.brandGreen,
  isChecked: isRemember,
  text: language.rememberMe,
  textStyle: secondaryTextStyle(),
  size: 20,
  // ... other properties
),

// Forgot Password Link
Text(
  language.forgotPassword,
  style: boldTextStyle(
    color: context.brandColors.brandRed,
    fontStyle: FontStyle.italic
  ),
  textAlign: TextAlign.right,
),

// Sign In Button
AppButton(
  text: language.signIn,
  color: context.brandColors.brandBlue,
  textColor: Colors.white,
  textStyle: boldTextStyle(color: Colors.white, fontFamily: 'Gluten'),
  width: context.width() - context.navigationBarHeight,
  onTap: () {
    _handleLogin();
  },
),

// Sign Up Link
Text(
  language.signUp,
  style: boldTextStyle(
    color: context.brandColors.brandBlue,
    decoration: TextDecoration.underline,
    fontFamily: 'Gluten',
  ),
),

// Register as Partner Link
Text(
  language.lblRegisterAsPartner,
  style: boldTextStyle(color: context.brandColors.brandBlue)
),
```

Update social login buttons:

```dart
// Google Login Button Background
Container(
  padding: EdgeInsets.all(12),
  decoration: boxDecorationWithRoundedCorners(
    backgroundColor: context.brandColors.brandRed.withValues(alpha: 0.1),
    boxShape: BoxShape.circle,
  ),
  child: GoogleLogoWidget(size: 16),
),

// OTP Login Button Background
Container(
  padding: EdgeInsets.all(8),
  decoration: boxDecorationWithRoundedCorners(
    backgroundColor: context.brandColors.brandYellow.withValues(alpha: 0.1),
    boxShape: BoxShape.circle,
  ),
  child: ic_calling.iconImage(size: 18, color: context.brandColors.brandYellow).paddingAll(4),
),

// Apple Login Button Background
Container(
  padding: EdgeInsets.all(8),
  decoration: boxDecorationWithRoundedCorners(
    backgroundColor: context.brandColors.brandGreen.withValues(alpha: 0.1),
    boxShape: BoxShape.circle,
  ),
  child: Icon(Icons.apple, color: context.brandColors.brandGreen),
),
```

## 5. Sign-Up Screen Updates

### File: `lib/screens/auth/sign_up_screen.dart`

Add import:

```dart
import 'package:booking_system_flutter/app_theme.dart';
```

Update top widget:

```dart
Widget _buildTopWidget() {
  return Column(
    children: [
      (context.height() * 0.12).toInt().height,
      Container(
        height: 80,
        width: 80,
        padding: EdgeInsets.all(16),
        child: ic_profile2.iconImage(color: Colors.white),
        decoration: boxDecorationDefault(
          shape: BoxShape.circle,
          color: context.brandColors.brandBlue
        ),
      ),
      16.height,
      Text(
        language.lblHelloUser,
        style: boldTextStyle(
          size: 22,
          color: context.brandColors.brandBlue,
          fontFamily: 'Gluten',
        )
      ).center(),
      16.height,
      Text(
        language.lblSignUpSubTitle,
        style: secondaryTextStyle(size: 14),
        textAlign: TextAlign.center
      ).center().paddingSymmetric(horizontal: 32),
    ],
  );
}
```

Update all form fields with the same pattern as sign-in:

```dart
// Apply to all input fields (First Name, Last Name, Username, Email, Mobile, Password)
decoration: inputDecoration(context, labelText: language.hintFirstNameTxt).copyWith(
  labelStyle: primaryTextStyle(color: context.brandColors.brandGreen),
  enabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: context.brandColors.brandGreen, width: 2),
  ),
  focusedBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: context.brandColors.brandGreen, width: 2),
  ),
),
suffix: ic_profile2.iconImage(size: 10, color: context.brandColors.brandGreen).paddingAll(14),
```

Update sign up button:

```dart
AppButton(
  text: language.signUp,
  color: context.brandColors.brandBlue,
  textColor: Colors.white,
  textStyle: boldTextStyle(color: Colors.white, fontFamily: 'Gluten'),
  width: context.width() - context.navigationBarHeight,
  onTap: () {
    // ... existing logic
  },
),
```

Update terms and conditions links:

```dart
TextSpan(
  text: language.lblTermsOfService,
  style: boldTextStyle(color: context.brandColors.brandBlue, size: 14),
  // ... recognizer
),
TextSpan(
  text: language.privacyPolicy,
  style: boldTextStyle(color: context.brandColors.brandBlue, size: 14),
  // ... recognizer
),
```

Update "Sign In" link:

```dart
TextSpan(
  text: language.signIn,
  style: boldTextStyle(
    color: context.brandColors.brandBlue,
    size: 14,
    fontFamily: 'Gluten'
  ),
  // ... recognizer
),
```

## 6. Additional Colorful Components

### Status Colors Usage

The status colors are automatically applied throughout the app for booking statuses, activity indicators, and other status-related UI elements.

### Dashboard Components

Apply brand colors to dashboard cards and components:

```dart
// Example dashboard card
Container(
  decoration: BoxDecoration(
    color: context.brandColors.brandBlue.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: context.brandColors.brandBlue.withValues(alpha: 0.3)),
  ),
  child: // ... card content
),
```

### Buttons and Interactive Elements

Apply consistent coloring to all buttons:

```dart
// Primary Action Button
AppButton(
  color: context.brandColors.brandBlue,
  textStyle: boldTextStyle(color: Colors.white, fontFamily: 'Gluten'),
  // ... other properties
),

// Secondary Action Button
AppButton(
  color: context.brandColors.brandGreen,
  textStyle: boldTextStyle(color: Colors.white, fontFamily: 'Gluten'),
  // ... other properties
),

// Warning/Cancel Button
AppButton(
  color: context.brandColors.brandRed,
  textStyle: boldTextStyle(color: Colors.white, fontFamily: 'Gluten'),
  // ... other properties
),
```

## 7. Implementation Checklist

### Required Files to Update:

- [ ] `lib/utils/colors.dart` - Add brand colors
- [ ] `lib/app_theme.dart` - Add theme extension system
- [ ] `pubspec.yaml` - Add Gluten font configuration
- [ ] `assets/fonts/` - Add Gluten font files
- [ ] `lib/screens/auth/sign_in_screen.dart` - Colorful login screen
- [ ] `lib/screens/auth/sign_up_screen.dart` - Colorful registration screen

### Optional Enhancements:

- [ ] Update splash screen with brand colors
- [ ] Apply colors to dashboard components
- [ ] Update booking status indicators
- [ ] Colorize navigation elements
- [ ] Apply brand colors to dialogs and modals

## 8. Testing

After implementation:

1. Test both light and dark themes
2. Verify all input fields show green styling
3. Check button colors match brand guidelines
4. Ensure text readability with new colors
5. Test on different screen sizes
6. Verify accessibility compliance

## 9. Notes

- **Font Usage**: Use 'Gluten' for headings and buttons, 'Alexandria' for body text
- **Color Consistency**: Always use `context.brandColors.brandX` instead of hardcoded colors
- **Theme Support**: The system automatically adapts colors for light/dark themes
- **Accessibility**: Ensure sufficient contrast ratios for all color combinations

This implementation provides a vibrant, cohesive color scheme that enhances the user experience while maintaining professional appearance and accessibility standards.
