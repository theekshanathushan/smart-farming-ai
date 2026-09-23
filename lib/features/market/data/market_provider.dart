import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final marketPricesProvider = FutureProvider<List<dynamic>>((ref) async {
  const baseUrl = 'http://10.16.135.91:8000';
  
  try {
    final response = await http.get(Uri.parse('$baseUrl/api/v1/market-prices')).timeout(
      const Duration(seconds: 3),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] as List<dynamic>;
    }
  } catch (e) {
    // Fallback if backend is offline
  }

  // Comprehensive realistic data for Sri Lankan market (Dambulla, Pettah, Nuwara Eliya, etc.)
  await Future.delayed(const Duration(milliseconds: 400));
  return [
    {
      'crop': 'Tomato',
      'category': 'vegetable',
      'price': 150.0,
      'unit': 'kg',
      'trend': 'down',
      'changePercent': '-8%',
      'market': 'Dambulla',
      'minPrice': 130.0,
      'maxPrice': 170.0,
      'wholesalePrice': 135.0,
      'retailPrice': 170.0,
      'otherMarkets': [
        {'market': 'Pettah', 'price': 170.0},
        {'market': 'Keppetipola', 'price': 140.0},
        {'market': 'Kandy', 'price': 160.0},
      ],
      'aiInsight': {
        'si': 'දඹුල්ල වෙළඳපොලට තොග වැඩි වශයෙන් ලැබීම නිසා මිල තරමක් පහත වැටී ඇත. ඉක්මනින් අලෙවි කිරීම හෝ සකස් කිරීම වඩාත් සුදුසුය.',
        'ta': 'தம்புள்ளை சந்தைக்கு வரத்து அதிகரித்துள்ளதால் விலை சற்று குறைந்துள்ளது. விரைவாக விற்க அல்லது பதப்படுத்த பரிந்துரைக்கப்படுகிறது.',
        'en': 'High arrival volumes in Dambulla have led to slight price drops. Recommended to sell quickly or process into paste.'
      }
    },
    {
      'crop': 'Carrot',
      'category': 'vegetable',
      'price': 380.0,
      'unit': 'kg',
      'trend': 'up',
      'changePercent': '+12%',
      'market': 'Nuwara Eliya',
      'minPrice': 350.0,
      'maxPrice': 420.0,
      'wholesalePrice': 360.0,
      'retailPrice': 410.0,
      'otherMarkets': [
        {'market': 'Dambulla', 'price': 390.0},
        {'market': 'Pettah', 'price': 420.0},
        {'market': 'Keppetipola', 'price': 370.0},
      ],
      'aiInsight': {
        'si': 'මධ්‍යම කඳුකරයේ අස්වැන්න අඩුවීම නිසා කැරට් සඳහා ඉහළ ඉල්ලුමක් පවතී. අස්වැන්න නෙළා වෙළඳපොලට යැවීමට සුදුසුම කාලයයි.',
        'ta': 'மத்திய மலைநாட்டில் அறுவடை குறைந்ததால் கேரட்டுக்கு அதிக தேவை உள்ளது. அறுவடை செய்து சந்தைக்கு அனுப்ப இதுவே சிறந்த நேரம்.',
        'en': 'Lower harvests in the central hills have driven up demand. Excellent time to harvest and bring to wholesale markets.'
      }
    },
    {
      'crop': 'Samba Rice',
      'category': 'grain',
      'price': 240.0,
      'unit': 'kg',
      'trend': 'stable',
      'changePercent': '0%',
      'market': 'Dambulla',
      'minPrice': 235.0,
      'maxPrice': 245.0,
      'wholesalePrice': 230.0,
      'retailPrice': 245.0,
      'otherMarkets': [
        {'market': 'Pettah', 'price': 245.0},
        {'market': 'Thambuththegama', 'price': 235.0},
        {'market': 'Kandy', 'price': 242.0},
      ],
      'aiInsight': {
        'si': 'සම්බා සහල් මිල ස්ථාවර මට්ටමක පවතී. ගබඩා කර තබා ගැනීමේ අවදානමක් නොමැති අතර ක්‍රමානුකූලව අලෙවි කළ හැක.',
        'ta': 'சம்பா அரிசி விலை நிலையாக உள்ளது. சேமித்து வைப்பதில் ஆபத்து இல்லை, சீராக விற்கலாம்.',
        'en': 'Samba rice prices remain stable. Safe to store in dry conditions and sell systematically.'
      }
    },
    {
      'crop': 'Green Chilli',
      'category': 'vegetable',
      'price': 550.0,
      'unit': 'kg',
      'trend': 'up',
      'changePercent': '+18%',
      'market': 'Dambulla',
      'minPrice': 500.0,
      'maxPrice': 620.0,
      'wholesalePrice': 520.0,
      'retailPrice': 600.0,
      'otherMarkets': [
        {'market': 'Pettah', 'price': 600.0},
        {'market': 'Kandy', 'price': 570.0},
        {'market': 'Meegoda', 'price': 580.0},
      ],
      'aiInsight': {
        'si': 'අමු මිරිස් සැපයුම අඩුවීම නිසා මිල ශීඝ්‍රයෙන් ඉහළ යමින් පවතී. ඉහළ ලාභයක් ලබා ගැනීමට හොඳ අවස්ථාවකි.',
        'ta': 'பச்சை மிளகாய் வரத்து குறைந்ததால் விலை வேகமாக உயர்ந்து வருகிறது. அதிக லாபம் ஈட்ட நல்ல வாய்ப்பு.',
        'en': 'Green chilli supply is tight, creating strong upward price pressure. Great window for quick market dispatch.'
      }
    },
    {
      'crop': 'Big Onion',
      'category': 'vegetable',
      'price': 310.0,
      'unit': 'kg',
      'trend': 'up',
      'changePercent': '+7%',
      'market': 'Pettah',
      'minPrice': 290.0,
      'maxPrice': 330.0,
      'wholesalePrice': 295.0,
      'retailPrice': 325.0,
      'otherMarkets': [
        {'market': 'Dambulla', 'price': 305.0},
        {'market': 'Kandy', 'price': 315.0},
      ],
      'aiInsight': {
        'si': 'ආනයනික තොග සීමාවීම නිසා දේශීය ලොකු ළූණු සඳහා හොඳ ඉල්ලුමක් නිර්මාණය වී ඇත.',
        'ta': 'இறக்குமதி வரத்து குறைந்ததால் உள்ளூர் பெரிய வெங்காயத்திற்கு நல்ல தேவை ஏற்பட்டுள்ளது.',
        'en': 'Import restrictions and seasonal shifts are favoring local big onion pricing.'
      }
    },
    {
      'crop': 'Potato',
      'category': 'vegetable',
      'price': 220.0,
      'unit': 'kg',
      'trend': 'stable',
      'changePercent': '+1%',
      'market': 'Nuwara Eliya',
      'minPrice': 210.0,
      'maxPrice': 235.0,
      'wholesalePrice': 210.0,
      'retailPrice': 230.0,
      'otherMarkets': [
        {'market': 'Keppetipola', 'price': 215.0},
        {'market': 'Pettah', 'price': 230.0},
      ],
      'aiInsight': {
        'si': 'නුවරඑළිය සහ වැලිමඩ අර්තාපල් අස්වැන්න සාමාන්‍ය මට්ටමක පවතින බැවින් මිල ස්ථාවරව පවතී.',
        'ta': 'உருளைக்கிழங்கு அறுவடை சீராக உள்ளதால் விலை நிலையாக உள்ளது.',
        'en': 'Steady local production from Nuwara Eliya and Welimada keeps potato prices predictable.'
      }
    },
    {
      'crop': 'Beans',
      'category': 'vegetable',
      'price': 340.0,
      'unit': 'kg',
      'trend': 'up',
      'changePercent': '+10%',
      'market': 'Keppetipola',
      'minPrice': 310.0,
      'maxPrice': 370.0,
      'wholesalePrice': 320.0,
      'retailPrice': 360.0,
      'otherMarkets': [
        {'market': 'Dambulla', 'price': 350.0},
        {'market': 'Pettah', 'price': 365.0},
      ],
      'aiInsight': {
        'si': 'බෝංචි සඳහා දිවයින පුරා පාරිභෝගික ඉල්ලුම ඉහළ ගොස් ඇත. නැවුම් අස්වැන්න ඉහළම මිලකට විකිණිය හැක.',
        'ta': 'பீன்ஸுக்கு நுகர்வோர் தேவை அதிகரித்துள்ளது. புதிய விளைச்சலுக்கு சிறந்த விலை கிடைக்கும்.',
        'en': 'High retail velocity for fresh beans. Maintain sorting and grade quality for best auction returns.'
      }
    },
    {
      'crop': 'Brinjal',
      'category': 'vegetable',
      'price': 230.0,
      'unit': 'kg',
      'trend': 'down',
      'changePercent': '-6%',
      'market': 'Dambulla',
      'minPrice': 200.0,
      'maxPrice': 250.0,
      'wholesalePrice': 210.0,
      'retailPrice': 245.0,
      'otherMarkets': [
        {'market': 'Pettah', 'price': 240.0},
        {'market': 'Meegoda', 'price': 235.0},
      ],
      'aiInsight': {
        'si': 'වම්බටු සැපයුම ඉහළ ගොස් ඇති බැවින් දිනපතා නෙළා ඉක්මනින් අලෙවි කිරීම පාඩු අවම කරයි.',
        'ta': 'கத்தரிக்காய் வரத்து அதிகமாக இருப்பதால் தினசரி அறுவடை செய்து விற்பது சிறந்தது.',
        'en': 'High regional supply in Dambulla; harvest continuously to preserve grade freshness.'
      }
    },
    {
      'crop': 'Cabbage',
      'category': 'vegetable',
      'price': 160.0,
      'unit': 'kg',
      'trend': 'down',
      'changePercent': '-5%',
      'market': 'Keppetipola',
      'minPrice': 140.0,
      'maxPrice': 180.0,
      'wholesalePrice': 145.0,
      'retailPrice': 175.0,
      'otherMarkets': [
        {'market': 'Dambulla', 'price': 165.0},
        {'market': 'Nuwara Eliya', 'price': 155.0},
      ],
      'aiInsight': {
        'si': 'කැප්පෙටිපොල ප්‍රදේශයෙන් ගෝවා තොග වැඩි වශයෙන් ලැබෙන බැවින් ඉදිරි දිනවලදී මිල ස්ථාවර වනු ඇත.',
        'ta': 'முட்டைக்கோஸ் வரத்து அதிகமாக உள்ளது, அடுத்த சில நாட்களில் விலை சீராகும்.',
        'en': 'Strong inflows from Keppetipola; prices expected to consolidate over the weekend.'
      }
    },
    {
      'crop': 'Pumpkin',
      'category': 'vegetable',
      'price': 140.0,
      'unit': 'kg',
      'trend': 'stable',
      'changePercent': '0%',
      'market': 'Dambulla',
      'minPrice': 125.0,
      'maxPrice': 155.0,
      'wholesalePrice': 130.0,
      'retailPrice': 150.0,
      'otherMarkets': [
        {'market': 'Pettah', 'price': 150.0},
        {'market': 'Thambuththegama', 'price': 130.0},
      ],
      'aiInsight': {
        'si': 'වට්ටක්කා කල්තබාගත හැකි බෝගයක් බැවින් මිල උච්චාවචනයන්ට මුහුණදීමට ගබඩා කර තබාගත හැක.',
        'ta': 'பூசணிக்காய் நீண்ட காலம் கெடாமல் இருக்கும் பயிர் என்பதால் தேவைக்கேற்ப சேமித்து விற்கலாம்.',
        'en': 'Pumpkin offers long shelf life. Farmers can hold stocks if local prices soften.'
      }
    },
    {
      'crop': 'Red Onion',
      'category': 'vegetable',
      'price': 480.0,
      'unit': 'kg',
      'trend': 'up',
      'changePercent': '+14%',
      'market': 'Dambulla',
      'minPrice': 450.0,
      'maxPrice': 520.0,
      'wholesalePrice': 460.0,
      'retailPrice': 510.0,
      'otherMarkets': [
        {'market': 'Pettah', 'price': 500.0},
        {'market': 'Kandy', 'price': 490.0},
      ],
      'aiInsight': {
        'si': 'යාපනය සහ පුත්තලම ප්‍රදේශවල රතු ළූණු සඳහා ඉහළ මිලක් නියම වී ඇත.',
        'ta': 'சின்ன வெங்காயத்திற்கு சந்தையில் அதிக தேவை மற்றும் நல்ல விலை கிடைக்கிறது.',
        'en': 'Jaffna and Puttalam red onion varieties are fetching prime wholesale margins.'
      }
    },
    {
      'crop': 'Leeks',
      'category': 'vegetable',
      'price': 260.0,
      'unit': 'kg',
      'trend': 'stable',
      'changePercent': '+2%',
      'market': 'Nuwara Eliya',
      'minPrice': 240.0,
      'maxPrice': 280.0,
      'wholesalePrice': 245.0,
      'retailPrice': 275.0,
      'otherMarkets': [
        {'market': 'Pettah', 'price': 275.0},
        {'market': 'Keppetipola', 'price': 255.0},
      ],
      'aiInsight': {
        'si': 'ලීක්ස් මිල ස්ථාවර මට්ටමක පවතී. හෝටල් සහ නාගරික වෙළඳපොල ඉල්ලුම යහපත්ය.',
        'ta': 'லீக்ஸ் விலை சீராக உள்ளது. நகர்ப்புற சந்தைகளில் நிலையான விற்பனை உள்ளது.',
        'en': 'Leeks prices remain balanced with reliable urban and hospitality sector demand.'
      }
    },
    {
      'crop': 'Beetroot',
      'category': 'vegetable',
      'price': 290.0,
      'unit': 'kg',
      'trend': 'up',
      'changePercent': '+8%',
      'market': 'Keppetipola',
      'minPrice': 260.0,
      'maxPrice': 320.0,
      'wholesalePrice': 275.0,
      'retailPrice': 310.0,
      'otherMarkets': [
        {'market': 'Dambulla', 'price': 295.0},
        {'market': 'Pettah', 'price': 310.0},
      ],
      'aiInsight': {
        'si': 'බීට්රූට් සැපයුම අඩු බැවින් ඉදිරි සති දෙක තුළ මිල තවදුරටත් ඉහළ යා හැක.',
        'ta': 'பீட்ரூட் வரத்து குறைவாக உள்ளதால் விலை மேலும் உயர வாய்ப்புள்ளது.',
        'en': 'Moderate supply constraints suggest beetroot prices will remain firm.'
      }
    },
    {
      'crop': 'Bitter Gourd',
      'category': 'vegetable',
      'price': 320.0,
      'unit': 'kg',
      'trend': 'up',
      'changePercent': '+9%',
      'market': 'Dambulla',
      'minPrice': 290.0,
      'maxPrice': 350.0,
      'wholesalePrice': 300.0,
      'retailPrice': 345.0,
      'otherMarkets': [
        {'market': 'Pettah', 'price': 340.0},
        {'market': 'Meegoda', 'price': 330.0},
      ],
      'aiInsight': {
        'si': 'කරවිල සඳහා නිරන්තර ඉහළ ඉල්ලුමක් පවතින බැවින් සාර්ථක අස්වැන්නක් ලබාගත හැක.',
        'ta': 'பாகற்காய்க்கு எப்போதும் நல்ல தேவை உள்ளது.',
        'en': 'Consistent consumer interest makes bitter gourd a lucrative crop this season.'
      }
    },
    {
      'crop': 'Ladies Finger',
      'category': 'vegetable',
      'price': 210.0,
      'unit': 'kg',
      'trend': 'down',
      'changePercent': '-4%',
      'market': 'Dambulla',
      'minPrice': 190.0,
      'maxPrice': 230.0,
      'wholesalePrice': 195.0,
      'retailPrice': 225.0,
      'otherMarkets': [
        {'market': 'Pettah', 'price': 225.0},
      ],
      'aiInsight': {
        'si': 'බණ්ඩක්කා ලපටි අවධියේදීම නෙළා අලෙවි කිරීමෙන් ඉහළ මිලක් ලබාගත හැක.',
        'ta': 'வெண்டைக்காயை இளம் பருவத்திலேயே பறித்து விற்பதால் நல்ல விலை கிடைக்கும்.',
        'en': 'Harvesting tender ladies finger guarantees grade-A wholesale valuation.'
      }
    },
    {
      'crop': 'Cucumber',
      'category': 'vegetable',
      'price': 110.0,
      'unit': 'kg',
      'trend': 'down',
      'changePercent': '-7%',
      'market': 'Dambulla',
      'minPrice': 90.0,
      'maxPrice': 130.0,
      'wholesalePrice': 95.0,
      'retailPrice': 125.0,
      'otherMarkets': [
        {'market': 'Meegoda', 'price': 120.0},
      ],
      'aiInsight': {
        'si': 'පිපිඤ්ඤා සැපයුම බහුල බැවින් ප්‍රවාහනයේදී හානි අවම වන සේ අසුරා යවන්න.',
        'ta': 'வெள்ளரிக்காய் வரத்து அதிகமாக உள்ளது, சேதமின்றி கொண்டு செல்வது அவசியம்.',
        'en': 'Abundant cucumber supply. Careful crate packing avoids in-transit spoilage.'
      }
    },
    {
      'crop': 'Banana',
      'category': 'fruit',
      'price': 180.0,
      'unit': 'kg',
      'trend': 'stable',
      'changePercent': '0%',
      'market': 'Dambulla',
      'minPrice': 160.0,
      'maxPrice': 200.0,
      'wholesalePrice': 165.0,
      'retailPrice': 195.0,
      'otherMarkets': [
        {'market': 'Pettah', 'price': 195.0},
        {'market': 'Kandy', 'price': 185.0},
      ],
      'aiInsight': {
        'si': 'ඇඹුල් සහ කෝලිකුට්ටු කෙසෙල් සඳහා ස්ථාවර දෛනික වෙළඳපොලක් පවතී.',
        'ta': 'வாழைப்பழத்திற்கு நிலையான தினசரி சந்தை உள்ளது.',
        'en': 'Consistent turnover for Ambul and Kolikuttu banana varieties across island hubs.'
      }
    },
    {
      'crop': 'Papaya',
      'category': 'fruit',
      'price': 130.0,
      'unit': 'kg',
      'trend': 'up',
      'changePercent': '+6%',
      'market': 'Dambulla',
      'minPrice': 115.0,
      'maxPrice': 150.0,
      'wholesalePrice': 120.0,
      'retailPrice': 145.0,
      'otherMarkets': [
        {'market': 'Pettah', 'price': 145.0},
      ],
      'aiInsight': {
        'si': 'රෙඩ් ලේඩි පැපොල් සඳහා පලතුරු සැකසුම් අංශයෙන් ඉහළ ඉල්ලුමක් පවතී.',
        'ta': 'ரெட் லேடி பப்பாளிக்கு பழச்சாறு தயாரிப்பாளர்களிடம் நல்ல தேவை உள்ளது.',
        'en': 'Red Lady papaya enjoys solid processing and beverage sector procurement.'
      }
    },
    {
      'crop': 'Lime',
      'category': 'fruit',
      'price': 620.0,
      'unit': 'kg',
      'trend': 'up',
      'changePercent': '+15%',
      'market': 'Dambulla',
      'minPrice': 580.0,
      'maxPrice': 680.0,
      'wholesalePrice': 590.0,
      'retailPrice': 650.0,
      'otherMarkets': [
        {'market': 'Pettah', 'price': 670.0},
      ],
      'aiInsight': {
        'si': 'වියළි කාලගුණය හේතුවෙන් දෙහි අස්වැන්න අඩු වී ඇති බැවින් මිල වාර්තාගත ලෙස ඉහළ ගොස් ඇත.',
        'ta': 'வறட்சியான காலநிலை காரணமாக எலுமிச்சை விளைச்சல் குறைந்து விலை கணிசமாக உயர்ந்துள்ளது.',
        'en': 'Dry weather reduced lime yields significantly, resulting in peak market pricing.'
      }
    },
    {
      'crop': 'Sweet Corn',
      'category': 'grain',
      'price': 175.0,
      'unit': 'kg',
      'trend': 'up',
      'changePercent': '+5%',
      'market': 'Dambulla',
      'minPrice': 160.0,
      'maxPrice': 195.0,
      'wholesalePrice': 165.0,
      'retailPrice': 190.0,
      'otherMarkets': [
        {'market': 'Pettah', 'price': 190.0},
      ],
      'aiInsight': {
        'si': 'බඩඉරිඟු සත්ව ආහාර සහ නැවුම් පරිභෝජනය යන දෙකටම හොඳ ඉල්ලුමක් ලබයි.',
        'ta': 'சோளம் மனித உணவு மற்றும் கால்நடை தீவனத்திற்கு நல்ல விலையில் விற்கப்படுகிறது.',
        'en': 'Dual demand from poultry feed industries and fresh boiled corn markets supports prices.'
      }
    },
    {
      'crop': 'Coconut',
      'category': 'grain',
      'price': 120.0,
      'unit': 'item',
      'trend': 'stable',
      'changePercent': '+2%',
      'market': 'Pettah',
      'minPrice': 110.0,
      'maxPrice': 130.0,
      'wholesalePrice': 110.0,
      'retailPrice': 125.0,
      'otherMarkets': [
        {'market': 'Dambulla', 'price': 115.0},
        {'market': 'Kurunegala', 'price': 105.0},
      ],
      'aiInsight': {
        'si': 'කුරුණෑගල සහ හලාවත ප්‍රදේශවල පොල් අස්වැන්න සාමාන්‍ය මට්ටමක පවතින බැවින් මිල ස්ථාවරය.',
        'ta': 'தேங்காய் வரத்து சீராக உள்ளதால் விலை நிலையாக நீடிக்கிறது.',
        'en': 'Coconut triangle production aligns closely with national domestic consumption.'
      }
    },
    {
      'crop': 'Ginger',
      'category': 'spice',
      'price': 1200.0,
      'unit': 'kg',
      'trend': 'up',
      'changePercent': '+10%',
      'market': 'Pettah',
      'minPrice': 1100.0,
      'maxPrice': 1350.0,
      'wholesalePrice': 1150.0,
      'retailPrice': 1300.0,
      'otherMarkets': [
        {'market': 'Dambulla', 'price': 1220.0},
        {'market': 'Kandy', 'price': 1250.0},
      ],
      'aiInsight': {
        'si': 'දේශීය ඉඟුරු සඳහා ඖෂධීය සහ කුළුබඩු අංශවලින් ඉතා ඉහළ ඉල්ලුමක් පවතී.',
        'ta': 'உள்ளூர் இஞ்சிக்கு மருந்து மற்றும் மசாலா துறைகளில் நல்ல கிராக்கி உள்ளது.',
        'en': 'Premium wholesale valuation for cured Sri Lankan ginger across medicinal and culinary channels.'
      }
    },
  ];
});
