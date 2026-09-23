// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Agri AI';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get updateProfilePhoto => 'Update Profile Photo';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get remove => 'Remove';

  @override
  String get personalDetails => 'Personal Details';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get location => 'Location';

  @override
  String get notProvided => 'Not provided';

  @override
  String get appSettings => 'App Settings';

  @override
  String get language => 'Language';

  @override
  String get aboutApp => 'About Agri AI';

  @override
  String get logout => 'Logout';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get selectLanguage => 'Select your language';

  @override
  String get english => 'English';

  @override
  String get sinhala => 'Sinhala (සිංහල)';

  @override
  String get tamil => 'Tamil (தமிழ்)';

  @override
  String get navHome => 'Home';

  @override
  String get navFarm => 'Farm';

  @override
  String get navScan => 'Scan';

  @override
  String get navMarket => 'Market';

  @override
  String get goodMorning => 'Good Morning,';

  @override
  String get farmer => 'Farmer';

  @override
  String get quickTools => 'Quick Tools';

  @override
  String get addCrop => 'Add Crop';

  @override
  String get fertilizer => 'Fertilizer';

  @override
  String get pestGuide => 'Pest Guide';

  @override
  String get aiHelper => 'AI Helper';

  @override
  String get irrigation => 'Irrigation';

  @override
  String get ledger => 'Ledger';

  @override
  String get community => 'Community';

  @override
  String get buySell => 'Buy & Sell';

  @override
  String get liveAlerts => 'Live Alerts';

  @override
  String get seeAll => 'See All';

  @override
  String get currentWeather => 'Current Weather';

  @override
  String get weatherUnavailable => 'Weather unavailable';

  @override
  String get empoweringFarmers => 'Empowering Farmers with AI';

  @override
  String get getStarted => 'Get Started';

  @override
  String get welcomeToAgriAi => 'Welcome to Agri AI';

  @override
  String get pleaseSelectLanguage => 'Please select your language';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get createAccount => 'Create Account';

  @override
  String get enterPhoneToContinue => 'Enter your phone number to continue';

  @override
  String get registerToAccess => 'Register to access agricultural insights';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get fullNameOrFarmName => 'Full Name or Farm Name';

  @override
  String get enterNameValidation => 'Please enter your name or farm name';

  @override
  String get enterPhoneValidation => 'Please enter your phone number';

  @override
  String get enterValidPhoneValidation => 'Please enter a valid phone number';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get registerAndSendOtp => 'Register & Send OTP';

  @override
  String get sendingOtp => 'Sending OTP...';

  @override
  String get verifyNumber => 'Verify Number';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get sentCodeTo => 'We sent a 6-digit code to';

  @override
  String get yourNumber => 'your number';

  @override
  String get digitOtpHint => '6-digit OTP';

  @override
  String get enterOtpValidation => 'Please enter the 6-digit OTP';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get didntReceiveCode => 'Didn\'t receive code? Resend';

  @override
  String get harvestMarketplace => 'Harvest Marketplace';

  @override
  String get directFromFarmers => 'Direct from local farmers';

  @override
  String get sellHarvest => 'Sell Harvest';

  @override
  String get myListings => 'My Listings';

  @override
  String get browseProduce => 'Browse Produce';

  @override
  String get searchProduceHint =>
      'Search crops (e.g. Tomato, Carrot, Jaffna)...';

  @override
  String get filterCategory => 'Category';

  @override
  String get allCategories => 'All';

  @override
  String get vegetables => 'Vegetables';

  @override
  String get fruits => 'Fruits';

  @override
  String get grains => 'Grains';

  @override
  String get spices => 'Spices';

  @override
  String get others => 'Others';

  @override
  String get noProduceFound => 'No produce found matching your search';

  @override
  String pricePerKg(String price, String unit) {
    return 'Rs. $price / $unit';
  }

  @override
  String availableQty(String qty, String unit) {
    return 'Available: $qty $unit';
  }

  @override
  String get contactFarmer => 'Contact Farmer';

  @override
  String get callSeller => 'Call Farmer';

  @override
  String get whatsAppSeller => 'WhatsApp';

  @override
  String get addNewHarvest => 'Post Harvest for Sale';

  @override
  String get cropName => 'Crop Name';

  @override
  String get cropNameHint => 'e.g. Big Onion, Tomato, Carrot';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get quantity => 'Quantity';

  @override
  String get unitLabel => 'Unit';

  @override
  String get pricePerUnitLabel => 'Selling Price (Rs. per unit)';

  @override
  String marketPriceSuggestion(String price) {
    return 'Today\'s wholesale ref: Rs. $price/kg';
  }

  @override
  String get qualityGrade => 'Quality Grade';

  @override
  String get gradeA => 'Grade A (Premium)';

  @override
  String get gradeB => 'Grade B (Standard)';

  @override
  String get organic => 'Organic (Certified / Natural)';

  @override
  String get harvestDateLabel => 'Harvest Date';

  @override
  String get districtLocation => 'District / Market Hub';

  @override
  String get selectDistrict => 'Select District';

  @override
  String get farmerContact => 'Farmer Contact Phone';

  @override
  String get descriptionOptional => 'Notes / Details (Optional)';

  @override
  String get descriptionHint =>
      'e.g. Freshly picked this morning, bulk transport available';

  @override
  String get publishListing => 'Publish Harvest Listing';

  @override
  String get markAsSold => 'Mark as Sold';

  @override
  String get soldOut => 'Sold Out';

  @override
  String get available => 'Available';

  @override
  String get deleteListing => 'Delete Listing';

  @override
  String get listingCreatedSuccess => 'Harvest listing posted successfully!';

  @override
  String get confirmDelete => 'Are you sure you want to delete this listing?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get harvestDetails => 'Harvest Details';

  @override
  String get farmerInfo => 'Farmer Information';

  @override
  String get marketSpikeAlert => 'Market Spike Alert';

  @override
  String get marketSpikeDesc =>
      'Tomato prices have increased by 15% in Dambulla market today.';

  @override
  String get oneHourAgo => '1 hour ago';

  @override
  String get weatherWarningAlert => 'Weather Warning';

  @override
  String get weatherWarningDesc =>
      'Heavy rain expected tomorrow evening. Postpone fertilizer application.';

  @override
  String get threeHoursAgo => '3 hours ago';

  @override
  String get cropScheduleAlert => 'Crop Schedule';

  @override
  String get cropScheduleDesc =>
      'It is time to water your Paddy field (Block A).';

  @override
  String get justNow => 'Just now';

  @override
  String get marketPricesTitle => 'Market Prices';

  @override
  String perUnit(String unit) {
    return 'per $unit';
  }

  @override
  String get trendUp => 'UP';

  @override
  String get trendDown => 'DOWN';

  @override
  String get trendStable => 'STABLE';

  @override
  String get identifyCropDisease => 'Identify Crop Disease';

  @override
  String get scanInstruction =>
      'Position the leaf clearly within the frame for best results.';

  @override
  String get scanNow => 'Scan Now';

  @override
  String get analyzingCrop => 'Analyzing crop...';

  @override
  String get keepDeviceSteady => 'Please keep the device steady.';

  @override
  String get analysisFailed => 'Analysis Failed';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get scanResult => 'Scan Result';

  @override
  String get attentionNeeded => 'Attention Needed';

  @override
  String get greatNews => 'Great News!';

  @override
  String confidence(String value) {
    return 'Confidence: $value%';
  }

  @override
  String severity(String value) {
    return 'Severity: $value';
  }

  @override
  String get savedToOfflineDb => 'Saved to offline database';

  @override
  String get saveResult => 'Save Result';

  @override
  String get saved => 'Saved';

  @override
  String get myFarmTitle => 'My Farm';

  @override
  String get myCrops => 'My Crops';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get dailyTasks => 'Daily Tasks';

  @override
  String get searchCrops => 'Search crops or markets...';

  @override
  String get grainsAndSpices => 'Grains & Spices';

  @override
  String get priceDetails => 'Price Details';

  @override
  String get minPrice => 'Minimum Price';

  @override
  String get maxPrice => 'Maximum Price';

  @override
  String get wholesalePrice => 'Wholesale Price';

  @override
  String get retailPrice => 'Retail Price';

  @override
  String get otherMarkets => 'Other Markets Comparison';

  @override
  String get aiMarketInsight => 'AI Market Advice';

  @override
  String get sellThisCrop => 'Sell This Produce';
}
