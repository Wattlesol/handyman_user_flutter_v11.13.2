import 'package:booking_system_flutter/utils/configs.dart';
import 'package:flutter/material.dart';

var primaryColor = defaultPrimaryColor;

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

// Legacy colors (keeping for compatibility)
const secondaryPrimaryColor = Color(0xfff3f4fa);
const lightPrimaryColor = Color(0xffebebf7);
const primaryLightColor = Color(0xFFEFEFF8);

//Text Color
const appTextPrimaryColor = Color(0xff1C1F34);
const appTextSecondaryColor = Color(0xff6C757D);
const cardColor = Color(0xFFF6F7F9);
const borderColor = Color(0xFFEBEBEB);

// Updated Dark Theme Colors
const scaffoldColorDark = Color(0xFF0F0F0F);
const scaffoldSecondaryDark = Color(0xFF1A1A1A);
const appButtonColorDark = Color(0xFF2A2A2A);

const ratingBarColor = brandYellowLight;
const verifyAcColor = brandBlueLight;
const favouriteColor = brandRedLight;
const unFavouriteColor = Colors.grey;
const lineTextColor = Color(0xFF6C757D);

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

const walletCardColor = Color(0xFF1C1E33);
const showRedForZeroRatingColor = Color(0xFFFA6565);

//Dashboard 3
const jobRequestComponentColor = Color(0xFFE4BB97);
const dashboard3CardColor = Color(0xFFF6F7F9);
const cancellationsBgColor = Color(0xFFFFE5E5);
