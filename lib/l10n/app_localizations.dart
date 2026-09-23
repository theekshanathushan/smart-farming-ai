import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Agri AI'**
  String get appTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @updateProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Update Profile Photo'**
  String get updateProfilePhoto;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About Agri AI'**
  String get aboutApp;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @sinhala.
  ///
  /// In en, this message translates to:
  /// **'Sinhala (සිංහල)'**
  String get sinhala;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'Tamil (தமிழ்)'**
  String get tamil;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navFarm.
  ///
  /// In en, this message translates to:
  /// **'Farm'**
  String get navFarm;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// No description provided for @navMarket.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get navMarket;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning,'**
  String get goodMorning;

  /// No description provided for @farmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmer;

  /// No description provided for @quickTools.
  ///
  /// In en, this message translates to:
  /// **'Quick Tools'**
  String get quickTools;

  /// No description provided for @addCrop.
  ///
  /// In en, this message translates to:
  /// **'Add Crop'**
  String get addCrop;

  /// No description provided for @fertilizer.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer'**
  String get fertilizer;

  /// No description provided for @pestGuide.
  ///
  /// In en, this message translates to:
  /// **'Pest Guide'**
  String get pestGuide;

  /// No description provided for @aiHelper.
  ///
  /// In en, this message translates to:
  /// **'AI Helper'**
  String get aiHelper;

  /// No description provided for @irrigation.
  ///
  /// In en, this message translates to:
  /// **'Irrigation'**
  String get irrigation;

  /// No description provided for @ledger.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get ledger;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @buySell.
  ///
  /// In en, this message translates to:
  /// **'Buy & Sell'**
  String get buySell;

  /// No description provided for @liveAlerts.
  ///
  /// In en, this message translates to:
  /// **'Live Alerts'**
  String get liveAlerts;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @currentWeather.
  ///
  /// In en, this message translates to:
  /// **'Current Weather'**
  String get currentWeather;

  /// No description provided for @weatherUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Weather unavailable'**
  String get weatherUnavailable;

  /// No description provided for @empoweringFarmers.
  ///
  /// In en, this message translates to:
  /// **'Empowering Farmers with AI'**
  String get empoweringFarmers;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @welcomeToAgriAi.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Agri AI'**
  String get welcomeToAgriAi;

  /// No description provided for @pleaseSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Please select your language'**
  String get pleaseSelectLanguage;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @enterPhoneToContinue.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to continue'**
  String get enterPhoneToContinue;

  /// No description provided for @registerToAccess.
  ///
  /// In en, this message translates to:
  /// **'Register to access agricultural insights'**
  String get registerToAccess;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @fullNameOrFarmName.
  ///
  /// In en, this message translates to:
  /// **'Full Name or Farm Name'**
  String get fullNameOrFarmName;

  /// No description provided for @enterNameValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name or farm name'**
  String get enterNameValidation;

  /// No description provided for @enterPhoneValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get enterPhoneValidation;

  /// No description provided for @enterValidPhoneValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get enterValidPhoneValidation;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @registerAndSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Register & Send OTP'**
  String get registerAndSendOtp;

  /// No description provided for @sendingOtp.
  ///
  /// In en, this message translates to:
  /// **'Sending OTP...'**
  String get sendingOtp;

  /// No description provided for @verifyNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify Number'**
  String get verifyNumber;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @sentCodeTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to'**
  String get sentCodeTo;

  /// No description provided for @yourNumber.
  ///
  /// In en, this message translates to:
  /// **'your number'**
  String get yourNumber;

  /// No description provided for @digitOtpHint.
  ///
  /// In en, this message translates to:
  /// **'6-digit OTP'**
  String get digitOtpHint;

  /// No description provided for @enterOtpValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit OTP'**
  String get enterOtpValidation;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive code? Resend'**
  String get didntReceiveCode;

  /// No description provided for @harvestMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Harvest Marketplace'**
  String get harvestMarketplace;

  /// No description provided for @directFromFarmers.
  ///
  /// In en, this message translates to:
  /// **'Direct from local farmers'**
  String get directFromFarmers;

  /// No description provided for @sellHarvest.
  ///
  /// In en, this message translates to:
  /// **'Sell Harvest'**
  String get sellHarvest;

  /// No description provided for @myListings.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get myListings;

  /// No description provided for @browseProduce.
  ///
  /// In en, this message translates to:
  /// **'Browse Produce'**
  String get browseProduce;

  /// No description provided for @searchProduceHint.
  ///
  /// In en, this message translates to:
  /// **'Search crops (e.g. Tomato, Carrot, Jaffna)...'**
  String get searchProduceHint;

  /// No description provided for @filterCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get filterCategory;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategories;

  /// No description provided for @vegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get vegetables;

  /// No description provided for @fruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get fruits;

  /// No description provided for @grains.
  ///
  /// In en, this message translates to:
  /// **'Grains'**
  String get grains;

  /// No description provided for @spices.
  ///
  /// In en, this message translates to:
  /// **'Spices'**
  String get spices;

  /// No description provided for @others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// No description provided for @noProduceFound.
  ///
  /// In en, this message translates to:
  /// **'No produce found matching your search'**
  String get noProduceFound;

  /// No description provided for @pricePerKg.
  ///
  /// In en, this message translates to:
  /// **'Rs. {price} / {unit}'**
  String pricePerKg(String price, String unit);

  /// No description provided for @availableQty.
  ///
  /// In en, this message translates to:
  /// **'Available: {qty} {unit}'**
  String availableQty(String qty, String unit);

  /// No description provided for @contactFarmer.
  ///
  /// In en, this message translates to:
  /// **'Contact Farmer'**
  String get contactFarmer;

  /// No description provided for @callSeller.
  ///
  /// In en, this message translates to:
  /// **'Call Farmer'**
  String get callSeller;

  /// No description provided for @whatsAppSeller.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsAppSeller;

  /// No description provided for @addNewHarvest.
  ///
  /// In en, this message translates to:
  /// **'Post Harvest for Sale'**
  String get addNewHarvest;

  /// No description provided for @cropName.
  ///
  /// In en, this message translates to:
  /// **'Crop Name'**
  String get cropName;

  /// No description provided for @cropNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Big Onion, Tomato, Carrot'**
  String get cropNameHint;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitLabel;

  /// No description provided for @pricePerUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Selling Price (Rs. per unit)'**
  String get pricePerUnitLabel;

  /// No description provided for @marketPriceSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Today\'s wholesale ref: Rs. {price}/kg'**
  String marketPriceSuggestion(String price);

  /// No description provided for @qualityGrade.
  ///
  /// In en, this message translates to:
  /// **'Quality Grade'**
  String get qualityGrade;

  /// No description provided for @gradeA.
  ///
  /// In en, this message translates to:
  /// **'Grade A (Premium)'**
  String get gradeA;

  /// No description provided for @gradeB.
  ///
  /// In en, this message translates to:
  /// **'Grade B (Standard)'**
  String get gradeB;

  /// No description provided for @organic.
  ///
  /// In en, this message translates to:
  /// **'Organic (Certified / Natural)'**
  String get organic;

  /// No description provided for @harvestDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Harvest Date'**
  String get harvestDateLabel;

  /// No description provided for @districtLocation.
  ///
  /// In en, this message translates to:
  /// **'District / Market Hub'**
  String get districtLocation;

  /// No description provided for @selectDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select District'**
  String get selectDistrict;

  /// No description provided for @farmerContact.
  ///
  /// In en, this message translates to:
  /// **'Farmer Contact Phone'**
  String get farmerContact;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes / Details (Optional)'**
  String get descriptionOptional;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Freshly picked this morning, bulk transport available'**
  String get descriptionHint;

  /// No description provided for @publishListing.
  ///
  /// In en, this message translates to:
  /// **'Publish Harvest Listing'**
  String get publishListing;

  /// No description provided for @markAsSold.
  ///
  /// In en, this message translates to:
  /// **'Mark as Sold'**
  String get markAsSold;

  /// No description provided for @soldOut.
  ///
  /// In en, this message translates to:
  /// **'Sold Out'**
  String get soldOut;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @deleteListing.
  ///
  /// In en, this message translates to:
  /// **'Delete Listing'**
  String get deleteListing;

  /// No description provided for @listingCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Harvest listing posted successfully!'**
  String get listingCreatedSuccess;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this listing?'**
  String get confirmDelete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @harvestDetails.
  ///
  /// In en, this message translates to:
  /// **'Harvest Details'**
  String get harvestDetails;

  /// No description provided for @farmerInfo.
  ///
  /// In en, this message translates to:
  /// **'Farmer Information'**
  String get farmerInfo;

  /// No description provided for @marketSpikeAlert.
  ///
  /// In en, this message translates to:
  /// **'Market Spike Alert'**
  String get marketSpikeAlert;

  /// No description provided for @marketSpikeDesc.
  ///
  /// In en, this message translates to:
  /// **'Tomato prices have increased by 15% in Dambulla market today.'**
  String get marketSpikeDesc;

  /// No description provided for @oneHourAgo.
  ///
  /// In en, this message translates to:
  /// **'1 hour ago'**
  String get oneHourAgo;

  /// No description provided for @weatherWarningAlert.
  ///
  /// In en, this message translates to:
  /// **'Weather Warning'**
  String get weatherWarningAlert;

  /// No description provided for @weatherWarningDesc.
  ///
  /// In en, this message translates to:
  /// **'Heavy rain expected tomorrow evening. Postpone fertilizer application.'**
  String get weatherWarningDesc;

  /// No description provided for @threeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'3 hours ago'**
  String get threeHoursAgo;

  /// No description provided for @cropScheduleAlert.
  ///
  /// In en, this message translates to:
  /// **'Crop Schedule'**
  String get cropScheduleAlert;

  /// No description provided for @cropScheduleDesc.
  ///
  /// In en, this message translates to:
  /// **'It is time to water your Paddy field (Block A).'**
  String get cropScheduleDesc;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @marketPricesTitle.
  ///
  /// In en, this message translates to:
  /// **'Market Prices'**
  String get marketPricesTitle;

  /// No description provided for @perUnit.
  ///
  /// In en, this message translates to:
  /// **'per {unit}'**
  String perUnit(String unit);

  /// No description provided for @trendUp.
  ///
  /// In en, this message translates to:
  /// **'UP'**
  String get trendUp;

  /// No description provided for @trendDown.
  ///
  /// In en, this message translates to:
  /// **'DOWN'**
  String get trendDown;

  /// No description provided for @trendStable.
  ///
  /// In en, this message translates to:
  /// **'STABLE'**
  String get trendStable;

  /// No description provided for @identifyCropDisease.
  ///
  /// In en, this message translates to:
  /// **'Identify Crop Disease'**
  String get identifyCropDisease;

  /// No description provided for @scanInstruction.
  ///
  /// In en, this message translates to:
  /// **'Position the leaf clearly within the frame for best results.'**
  String get scanInstruction;

  /// No description provided for @scanNow.
  ///
  /// In en, this message translates to:
  /// **'Scan Now'**
  String get scanNow;

  /// No description provided for @analyzingCrop.
  ///
  /// In en, this message translates to:
  /// **'Analyzing crop...'**
  String get analyzingCrop;

  /// No description provided for @keepDeviceSteady.
  ///
  /// In en, this message translates to:
  /// **'Please keep the device steady.'**
  String get keepDeviceSteady;

  /// No description provided for @analysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis Failed'**
  String get analysisFailed;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @scanResult.
  ///
  /// In en, this message translates to:
  /// **'Scan Result'**
  String get scanResult;

  /// No description provided for @attentionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Attention Needed'**
  String get attentionNeeded;

  /// No description provided for @greatNews.
  ///
  /// In en, this message translates to:
  /// **'Great News!'**
  String get greatNews;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence: {value}%'**
  String confidence(String value);

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity: {value}'**
  String severity(String value);

  /// No description provided for @savedToOfflineDb.
  ///
  /// In en, this message translates to:
  /// **'Saved to offline database'**
  String get savedToOfflineDb;

  /// No description provided for @saveResult.
  ///
  /// In en, this message translates to:
  /// **'Save Result'**
  String get saveResult;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @myFarmTitle.
  ///
  /// In en, this message translates to:
  /// **'My Farm'**
  String get myFarmTitle;

  /// No description provided for @myCrops.
  ///
  /// In en, this message translates to:
  /// **'My Crops'**
  String get myCrops;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @dailyTasks.
  ///
  /// In en, this message translates to:
  /// **'Daily Tasks'**
  String get dailyTasks;

  /// No description provided for @searchCrops.
  ///
  /// In en, this message translates to:
  /// **'Search crops or markets...'**
  String get searchCrops;

  /// No description provided for @grainsAndSpices.
  ///
  /// In en, this message translates to:
  /// **'Grains & Spices'**
  String get grainsAndSpices;

  /// No description provided for @priceDetails.
  ///
  /// In en, this message translates to:
  /// **'Price Details'**
  String get priceDetails;

  /// No description provided for @minPrice.
  ///
  /// In en, this message translates to:
  /// **'Minimum Price'**
  String get minPrice;

  /// No description provided for @maxPrice.
  ///
  /// In en, this message translates to:
  /// **'Maximum Price'**
  String get maxPrice;

  /// No description provided for @wholesalePrice.
  ///
  /// In en, this message translates to:
  /// **'Wholesale Price'**
  String get wholesalePrice;

  /// No description provided for @retailPrice.
  ///
  /// In en, this message translates to:
  /// **'Retail Price'**
  String get retailPrice;

  /// No description provided for @otherMarkets.
  ///
  /// In en, this message translates to:
  /// **'Other Markets Comparison'**
  String get otherMarkets;

  /// No description provided for @aiMarketInsight.
  ///
  /// In en, this message translates to:
  /// **'AI Market Advice'**
  String get aiMarketInsight;

  /// No description provided for @sellThisCrop.
  ///
  /// In en, this message translates to:
  /// **'Sell This Produce'**
  String get sellThisCrop;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
