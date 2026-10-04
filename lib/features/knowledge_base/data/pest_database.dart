class PestDisease {
  final String id;
  final String name;
  final String scientificName;
  final String crop;
  final String category;
  final String symptoms;
  final String prevention;
  final String organicControl;
  final String chemicalControl;
  final String imageAsset;

  const PestDisease({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.symptoms,
    required this.prevention,
    required this.imageAsset,
    this.crop = 'General',
    this.category = 'Pest & Disease',
    this.organicControl = '',
    this.chemicalControl = '',
  });
}

class PestDatabase {
  static const List<PestDisease> pests = [
    // --- PADDY (වී) ---
    PestDisease(
      id: 'p1',
      name: 'Brown Plant Hopper (දුඹුරු පැළ කීඩෑවා)',
      scientificName: 'Nilaparvata lugens',
      crop: 'Paddy (වී)',
      category: 'Insect Pest (කෘමියා)',
      symptoms: 'පඳුරේ පහළ කොටසේ යුෂ උරා බීම නිසා කොළ කහ පැහැ වී වේලී මැරී යයි. ක්ෂේත්‍රයේ තැනින් තැන රවුම් හැඩයට ගොයම වියළී යෑම (Hopper burn ලක්ෂණය).',
      prevention: 'ප්‍රතිරෝධී වී ප්‍රභේද (Bg 300, Bg 358) භාවිතා කිරීම. නියමිත පරතරය තබා පැළ සිටුවීම. අනවශ්‍ය ලෙස අධික නයිට්‍රජන් (යූරියා) යෙදීමෙන් වැළකීම.',
      organicControl: 'කුඹුරේ ජලය බැස යාමට සලස්වා දින 3-4ක් වියලිව තැබීම. කොහොඹ ඇට සාරය (Neem seed extract 5%) හෝ කොහොඹ තෙල් ඉසීම. ස්වාභාවික විලෝපිකයන් (මකුළුවන්, කුරුමිණියන්) ආරක්ෂා කිරීම.',
      chemicalControl: 'කීඩෑ ගහනය ආර්ථික හානි මට්ටම ඉක්මවූ විට Buprofezin 25% SC හෝ Pymetrozine 50% WG හෝ Dinotefuran නිර්දේශිත මාත්‍රාවට අනුව පඳුරු පාමුලට හොඳින් වදින සේ ඉසින්න.',
      imageAsset: 'assets/images/leaf_placeholder.jpg',
    ),
    PestDisease(
      id: 'p2',
      name: 'Rice Blast (වී කොළ පාළුව)',
      scientificName: 'Magnaporthe oryzae',
      crop: 'Paddy (වී)',
      category: 'Fungal Disease (දිලීරය)',
      symptoms: 'කොළ මත දෙකෙළවර උල් වූ දියමන්ති (කැරකැවිලි) හැඩැති අළු-දුඹුරු පැහැ ලප ඇතිවීම. කරල් පාමුල කුණු වී කරල් බොල් වී ඇද වැටීම (Neck Blast).',
      prevention: 'නිරෝගී සහතික කළ බීජ භාවිතය. බීජ තවාන් දැමීමට පෙර දිලීර නාශකයකින් බීජ ප්‍රතිකාර කිරීම. අධික යූරියා භාවිතය පාලනය කිරීම.',
      organicControl: 'බීජ පැය 24ක් උණුසුම් ජලයේ (52°C-54°C) හෝ තෝර කොළ/කොහොඹ දියරයේ පොඟවා තැබීම. සුදුළූණු හා ඉඟුරු සාරය මිශ්‍රණය යෙදීම.',
      chemicalControl: 'Tricyclazole 75% WP හෝ Isoprothiolane 40% EC හෝ Kasugamycin දිලීර නාශකය රෝග ලක්ෂණ දුටු වහාම පත්‍ර මතට ඉසින්න.',
      imageAsset: 'assets/images/leaf_placeholder.jpg',
    ),
    PestDisease(
      id: 'p3',
      name: 'Paddy Stem Borer (ගොයම් පුරුක් පණුවා)',
      scientificName: 'Scirpophaga incertulas',
      crop: 'Paddy (වී)',
      category: 'Insect Pest (කෘමියා)',
      symptoms: 'ගොයම් ගසේ කඳ ඇතුළත කා දැමීම නිසා වර්ධක අවධියේදී ගොබය මැරී යාම (Dead heart) සහ කරල් පීදෙන අවධියේදී බොල් සුදු කරල් හටගැනීම (White head).',
      prevention: 'අස්වැන්න නෙලූ පසු ඉතිරිවන මුල් හා පිදුරු පුළුස්සා හෝ සීසා පස් යට කිරීම. ආලෝක උගුල් මඟින් සලබයන් ආකර්ෂණය කර විනාශ කිරීම.',
      organicControl: 'ට්‍රයිකොග්‍රැමා (Trichogramma) බිත්තර පරපෝෂිතයන් කුඹුරට මුදාහැරීම. බැසිලස් තුරින්ජියෙන්සිස් (Bt) ජෛව කෘමිනාශකය යෙදීම.',
      chemicalControl: 'හානි ලක්ෂණ 5% ඉක්මවූ විට Chlorantraniliprole 18.5% SC හෝ Cartap hydrochloride 50% SP නිර්දේශිත පරිදි යොදන්න.',
      imageAsset: 'assets/images/leaf_placeholder.jpg',
    ),
    PestDisease(
      id: 'p4',
      name: 'Bacterial Leaf Blight (බැක්ටීරියා කොළ අංගමාරය)',
      scientificName: 'Xanthomonas oryzae pv. oryzae',
      crop: 'Paddy (වී)',
      category: 'Bacterial Disease (බැක්ටීරියාව)',
      symptoms: 'පත්‍ර අග සිට පහළට දාර දිගේ කහ-දුඹුරු පැහැති රැලි සහිත වියළී යාමේ ඉරි ඇතිවීම. උදෑසන පත්‍ර මත කහ පැහැති බැක්ටීරියා ස්‍රාවයන් දැකිය හැක (Kresek තත්ත්වය).',
      prevention: 'පිරිසිදු නිරෝගී බීජ භාවිතය. කෙත්වතු ආශ්‍රිත වල් පැලෑටි ඉවත් කිරීම. නයිට්‍රජන් හා පොටෑසියම් සමබරව යෙදීම.',
      organicControl: 'ගොම දියර හා කොහොඹ කොළ සාරය මුසු දියරය පත්‍ර මත ඉසීම. ක්ෂේත්‍රයේ ජලය සම්පූර්ණයෙන්ම බැසයාමට හැරීම.',
      chemicalControl: 'තඹ අඩංගු දිලීර/බැක්ටීරියා නාශක (Copper Hydroxide හෝ Copper Oxychloride) පත්‍ර මතට යොදන්න.',
      imageAsset: 'assets/images/leaf_placeholder.jpg',
    ),

    // --- CORN / MAIZE (බඩඉරිඟු) ---
    PestDisease(
      id: 'p5',
      name: 'Fall Armyworm (සේනා දළඹුවා)',
      scientificName: 'Spodoptera frugiperda',
      crop: 'Corn (බඩඉරිඟු)',
      category: 'Insect Pest (කෘමියා)',
      symptoms: 'බඩඉරිඟු කොළ කවුළු මෙන් විනිවිද පෙනෙන සේ කා දැමීම, කොළ රවුම් සිදුරු වීම. ගොබය ඇතුළේ කැටිති සහිත අසූචි සමඟ දළඹුවන් රැඳී සිටීම.',
      prevention: 'කන්නය ආරම්භයේදීම එකවර සියලු ගොවීන් වගා කිරීම. බඩඉරිඟු සමඟ රනිල බෝග අතුරු වගාවක් ලෙස යෙදීම (Push-Pull ක්‍රමය).',
      organicControl: 'ගොබය තුළට ලී අළු, සියුම් වැලි හෝ කොහොඹ ඇට කුඩු දැමීම. නිව්ක්ලියෝ පොලිහීඩ්‍රොවයිරසය (NPV) හෝ Bt භාවිතය.',
      chemicalControl: 'Spinetoram 11.7% SC, Emamectin Benzoate 5% SG, හෝ Chlorantraniliprole 18.5% SC ගොබය තුළට හොඳින් වදින පරිදි සවස් කාලයේ ඉසින්න.',
      imageAsset: 'assets/images/leaf_placeholder.jpg',
    ),

    // --- CHILLI (මිරිස්) ---
    PestDisease(
      id: 'p6',
      name: 'Chilli Leaf Curl Complex (මිරිස් කොළ කොඩවීම)',
      scientificName: 'Thrips, Mites & Begomovirus',
      crop: 'Chilli (මිරිස්)',
      category: 'Pest & Viral Complex',
      symptoms: 'කොළ උඩු අතට හෝ යටි අතට බෝට්ටුවක් සේ හැකිලී කොඩවීම. පත්‍ර නහර ඝන වීම, මල් හා කරල් හටගැනීම බාල වී ශාකය කුරු වීම.',
      prevention: 'කහ හා නිල් පැහැති ඇලෙන උගුල් (Sticky Traps) හෙක්ටයාරයකට 15-20ක් සවි කිරීම. මායිම් බෝග ලෙස බඩඉරිඟු පේළි 2-3ක් සිටුවීම.',
      organicControl: 'කොහොඹ තෙල් සහ සබන් දියර මිශ්‍රණය (Neem oil + soap water) දින 5කට වරක් යටි පත්‍ර තෙමෙන සේ ඉසීම. දුම්කොළ කසාය භාවිතය.',
      chemicalControl: 'පැළ මැක්කන්ට Spinotoram 11.7% SC හෝ Imidacloprid ද, මයිටාවන්ට Abamectin 1.8% EC හෝ Fenpyroximate 5% SC නිර්දේශිත මාත්‍රාවට මාරුවෙන් මාරුවට යොදන්න.',
      imageAsset: 'assets/images/leaf_placeholder.jpg',
    ),
    PestDisease(
      id: 'p7',
      name: 'Chilli Anthracnose / Fruit Rot (මිරිස් කරල් කුණුවීම)',
      scientificName: 'Colletotrichum capsici',
      crop: 'Chilli (මිරිස්)',
      category: 'Fungal Disease (දිලීරය)',
      symptoms: 'ඉදුණු හෝ අමු කරල් මත ගිලුණු, රවුම්, දුඹුරු-කළු පැහැති ලප හටගැනීම. ලප මධ්‍යයේ තැඹිලි හෝ කළු පැහැති බීජාණු වළලු හටගෙන කරල වියළී යයි.',
      prevention: 'හොඳ ජලාපවහනයක් ඇති උස් පාත්ති භාවිතය. බෝග නარටි සහ රෝගී කරල් විනාශ කිරීම. තෙතමනය රඳන සෙවන අවම කිරීම.',
      organicControl: 'ට්‍රයිකොඩර්මා (Trichoderma viride) දිලීරය පාංශු ප්‍රතිකාරයක් ලෙස යෙදීම. බීජ සිටුවීමට පෙර උණුසුම් ජලයෙන් සේදීම.',
      chemicalControl: 'Tebuconazole 250 EC, Difenoconazole 25% EC, හෝ Mancozeb 80% WP මල් පිපීම ආරම්භ වූ පසු දින 10කට වරක් ඉසින්න.',
      imageAsset: 'assets/images/leaf_placeholder.jpg',
    ),

    // --- TOMATO (තක්කාලි) ---
    PestDisease(
      id: 'p8',
      name: 'Tomato Late Blight (තක්කාලි අංගමාරය)',
      scientificName: 'Phytophthora infestans',
      crop: 'Tomato (තක්කාලි)',
      category: 'Fungal Disease (දිලීරය)',
      symptoms: 'පත්‍ර මත දියමන්ත හෝ අවිධිමත් ජලබිංදු හැඩයේ තෙත් දුඹුරු ලප ඇතිවීම. තෙත් කාලගුණයකදී කොළ යට සුදු පැහැ දිලීර වර්ධනයක් දැකිය හැක. ගෙඩි තද දුඹුරු වී කුණු වේ.',
      prevention: 'බිංදු ජල සම්පාදනය (Drip Irrigation) භාවිතය. පත්‍ර තෙමෙන පරිදි උඩින් ජලය නොයෙදීම. වාතාශ්‍රය ලැබෙන සේ කූඤ්ඤ සිටුවා වැල් බැඳීම.',
      organicControl: 'බෝඩෝ මිශ්‍රණය (Bordeaux mixture 1%) පත්‍ර මත ආවරණය වන සේ ඉසීම. කොහොඹ හා කරඳ ඇට දියර භාවිතය.',
      chemicalControl: 'රෝගය ආරම්භයේදී Mancozeb 80% WP හෝ Chlorothalonil ද, උග්‍ර අවස්ථාවේදී Metalaxyl-M + Mancozeb හෝ Dimethomorph ඉසින්න.',
      imageAsset: 'assets/images/leaf_placeholder.jpg',
    ),
    PestDisease(
      id: 'p9',
      name: 'Tomato Fruit Borer (තක්කාලි කේතු පණුවා)',
      scientificName: 'Helicoverpa armigera',
      crop: 'Tomato (තක්කාලි)',
      category: 'Insect Pest (කෘමියා)',
      symptoms: 'දළඹුවා තක්කාලි ගෙඩිය තුළට හිස ඔබා ඇතුළත මදය කා දැමීම. ගෙඩි මත රවුම් සිදුරු සහ අවට අසූචි දැකිය හැක. ගෙඩි නරක් වී හැලී යයි.',
      prevention: 'තක්කාලි වටා දාස්පෙතියා (Marigold) උගුල් බෝගයක් ලෙස සිටුවීම. ෆෙරමෝන් උගුල් (Pheromone traps) භාවිතය.',
      organicControl: 'බැසිලස් තුරින්ජියෙන්සිස් (Bt) හෝ Azadirachtin (කොහොඹ නිස්සාරකය) සවස් කාලයේ ඉසීම. අතින් අල්ලා විනාශ කිරීම.',
      chemicalControl: 'Chlorantraniliprole 18.5% SC හෝ Flubendiamide 480 SC හෝ Emamectin Benzoate නිර්දේශිත මාත්‍රාවට අනුව යොදන්න.',
      imageAsset: 'assets/images/leaf_placeholder.jpg',
    ),

    // --- BRINJAL / EGGPLANT (වම්බටු) ---
    PestDisease(
      id: 'p10',
      name: 'Brinjal Shoot & Fruit Borer (කරටි හා ගෙඩි විදින්නා)',
      scientificName: 'Leucinodes orbonalis',
      crop: 'Eggplant (වම්බටු)',
      category: 'Insect Pest (කෘමියා)',
      symptoms: 'ළපටි කරටි ඇතුළට විද කා දැමීම නිසා කරටි එල්ලී මැලවී යාම. ගෙඩි විදීම නිසා ගෙඩි ඇතුළත කුහර ඇති වී කුණු වීම.',
      prevention: 'හානි වූ කරටි සහ ගෙඩි නිරන්තරයෙන් කඩා දමා විනාශ කිරීම. පිරිමි සලබයන් ඇල්ලීමට ලියුසිනෝඩ්ස් ෆෙරමෝන් උගුල් සවි කිරීම.',
      organicControl: 'කොහොඹ තෙල් සබන් මිශ්‍රණය දින 7කට වරක් ඉසීම. ස්වාභාවික පරපෝෂිත බඹරුන් (Bracon hebetor) බෝ කිරීම.',
      chemicalControl: 'Chlorantraniliprole 18.5% SC, Spinosad 45% SC, හෝ Emamectin Benzoate මල් පිපීමෙන් පසු මාරුවෙන් මාරුවට යොදන්න.',
      imageAsset: 'assets/images/leaf_placeholder.jpg',
    ),
    PestDisease(
      id: 'p11',
      name: 'Bacterial Wilt (බැක්ටීරියා හිටුමැරීම)',
      scientificName: 'Ralstonia solanacearum',
      crop: 'Solanaceous (වම්බටු, තක්කාලි, අල)',
      category: 'Bacterial Disease (බැක්ටීරියාව)',
      symptoms: 'කොළ කහ වීමකින් තොරව සම්පූර්ණ ශාකය ක්ෂණිකව කොළ පැහැයෙන්ම මැලවී මැරී යාම. කඳ පාමුල කපා වතුර වීදුරුවක තැබූ විට සුදු පැහැති බැක්ටීරියා දුමාරයක් නිකුත් වීම.',
      prevention: 'පස සූර්යතාපනය (Soil solarization) කිරීම. වසර 3ක්වත් එම ක්ෂේත්‍රයේ සොලනේසියේ බෝග වගා නොකර බඩඉරිඟු හෝ වී සමඟ බෝග මාරුව.',
      organicControl: 'නිරෝගී පැළ පමණක් භාවිතය. පසට කොම්පෝස්ට් සමඟ ට්‍රයිකොඩර්මා සහ බැසිලස් සබ්ටිලිස් (Bacillus subtilis) එකතු කිරීම.',
      chemicalControl: 'බැක්ටීරියා හිටුමැරීම සඳහා පූර්ණ රසායනික ප්‍රතිකාර නොමැති බැවින් රෝගී ශාක මුලින්ම ගලවා පුළුස්සා එම වළට හුණු කුඩු යොදන්න.',
      imageAsset: 'assets/images/leaf_placeholder.jpg',
    ),

    // --- POTATO (අර්තාපල්) ---
    PestDisease(
      id: 'p12',
      name: 'Potato Late Blight (අර්තාපල් අංගමාරය)',
      scientificName: 'Phytophthora infestans',
      crop: 'Potato (අර්තාපල්)',
      category: 'Fungal Disease (දිලීරය)',
      symptoms: 'පත්‍ර දාරවල ජලබිඳු හැඩයේ කළු-දුඹුරු පැහැති තෙත් ලප ඇතිවීම. ශීඝ්‍රයෙන් සම්පූර්ණ පඳුරම කළු වී කුණු වීම. අල මතුපිට දම්-දුඹුරු ලප ඇති වී ඇතුළත වියළි කුණුවීම හටගැනීම.',
      prevention: 'නිරෝගී බීජ අල භාවිතය. පස් දැමීමේදී අල හොඳින් පස්වලින් ආවරණය කිරීම. අධික තෙතමනය රඳන අවස්ථාවල පූර්ව ආරක්ෂක පියවර ගැනීම.',
      organicControl: 'බෝඩෝ මිශ්‍රණය 1% පත්‍ර දෙපසම හොඳින් තෙමෙන සේ සතිපතා ඉසීම.',
      chemicalControl: 'රෝග පූර්වයෙන් Mancozeb 80% WP හෝ Propineb 70% WP ද, රෝගය වැළඳුණු පසු Dimethomorph 50% WP හෝ Cymoxanil + Mancozeb යොදන්න.',
      imageAsset: 'assets/images/leaf_placeholder.jpg',
    ),

    // --- CABBAGE (ගෝවා) ---
    PestDisease(
      id: 'p13',
      name: 'Diamondback Moth (ගෝවා කොළ දළඹුවා)',
      scientificName: 'Plutella xylostella',
      crop: 'Cabbage (ගෝවා)',
      category: 'Insect Pest (කෘමියා)',
      symptoms: 'පත්‍රවල යටි පැත්තේ පටක කා දැමීම නිසා කොළ මත කුඩා සිදුරු හා විනිවිද පෙනෙන කවුළු ඇතිවීම. ගෝවා ගෙඩිය සැකසෙන විට ඇතුළට විද හානි කිරීම.',
      prevention: 'ගෝවා සමඟ අබ (Mustard) උගුල් බෝගයක් ලෙස වටේට වගා කිරීම. කහ ඇලෙන උගුල් යෙදීම.',
      organicControl: 'බැසිලස් තුරින්ජියෙන්සිස් (Bt kurstaki) සවස් වරුවේ ඉසීම. කොහොඹ ඇට සාරය (NSKE 5%) භාවිතය.',
      chemicalControl: 'Spinosad 45% SC හෝ Chlorantraniliprole 18.5% SC හෝ Flubendiamide නිර්දේශිත අනුපාතයට ඉසින්න.',
      imageAsset: 'assets/images/leaf_placeholder.jpg',
    ),

    // --- ONION (ලූනු) ---
    PestDisease(
      id: 'p14',
      name: 'Onion Purple Blotch (ලූනු දම් ලප රෝගය)',
      scientificName: 'Alternaria porri',
      crop: 'Onion (ලූනු)',
      category: 'Fungal Disease (දිලීරය)',
      symptoms: 'කොළ සහ මල් දඬු මත මධ්‍යයේ දම් හෝ දුඹුරු පැහැති දිගටි ලප හටගැනීම. ලප වටා කහ පැහැති වලල්ලක් ඇති අතර කොළ මැදින් කඩා වැටී වේලී යයි.',
      prevention: 'නියමිත පරතරය තබා සිටුවීම. උස් පාත්ති මත වගා කර හොඳින් ජලය බැසයාමට සැලැස්වීම.',
      organicControl: 'බීජ සිටුවීමට පෙර ට්‍රයිකොඩර්මා සමඟ මිශ්‍ර කිරීම. කොහොඹ තෙල් සාරය භාවිතය.',
      chemicalControl: 'Difenoconazole 25% EC හෝ Tebuconazole හෝ Mancozeb දින 7-10 කට වරක් සවස් කාලයේ ඉසින්න.',
      imageAsset: 'assets/images/leaf_placeholder.jpg',
    ),

    // --- BANANA (කෙසෙල්) ---
    PestDisease(
      id: 'p15',
      name: 'Banana Panama Wilt (කෙසෙල් පැනමා රෝගය)',
      scientificName: 'Fusarium oxysporum f. sp. cubense',
      crop: 'Banana (කෙසෙල්)',
      category: 'Fungal Disease (දිලීරය)',
      symptoms: 'පහළ මුල් කොළ කහ පැහැ වී නටුව පාමුලින් බිඳී කඳ වටා එල්ලී වැටීම. කඳ හරස් අතට කැපූ විට වාහිනී පද්ධතිය දුඹුරු හෝ රතු පැහැ වී තිබීම.',
      prevention: 'රෝගයෙන් තොර පටක රෝපිත හෝ නිරෝගී මොර භාවිතය. ආසාදිත ක්ෂේත්‍රවලින් ආයුධ වෙනත් ගස් සඳහා භාවිත නොකිරීම.',
      organicControl: 'කෙසෙල් වළවල්වලට වේවැල් අළු හා කොම්පෝස්ට් සමඟ ට්‍රයිකොඩර්මා දිලීරය මිශ්‍ර කර පස සාරවත් කිරීම.',
      chemicalControl: 'පස තුළ ජීවත්වන දිලීරයක් බැවින් රෝගී ගස් මුලින්ම උගුල්ලා පුළුස්සා දමන්න. වළට හුණු කිලෝ 1-2ක් යොදා විෂබීජහරණය කරන්න.',
      imageAsset: 'assets/images/leaf_placeholder.jpg',
    ),

    // --- PAPAYA (පැපොල්) ---
    PestDisease(
      id: 'p16',
      name: 'Papaya Mealybug (පැපොල් පිටි මකුණා)',
      scientificName: 'Paracoccus marginatus',
      crop: 'Papaya (පැපොල්)',
      category: 'Insect Pest (කෘමියා)',
      symptoms: 'කොළ, මල් හා ගෙඩි යට සුදු පැහැති කපු පුළුන් වැනි පිටි ආවරණයකින් වැසී යුෂ උරා බීම. කොළ හැකිලී කහ වී වැටීම. මලමූත්‍ර මත කළු පැහැති පුස් (Sooty mold) හටගැනීම.',
      prevention: 'වතු පිරිසිදුව තබා ගැනීම. පිටි මකුණන් ප්‍රවාහනය කරන කෘමි කූඹින් (Ants) පාලනය කිරීම.',
      organicControl: 'ප්‍රබල ජල ධාරාවකින් ගස් සේදීම. සබන් කුඩු තේ හැඳි 2ක් වතුර ලීටරයකට මිශ්‍ර කර ඉසීම. කොහොඹ තෙල් භාවිතය. ඇසෙරෝෆාගස් පැපායේ (Acerophagus papayae) පරපෝෂිත බඹරුන් මුදාහැරීම.',
      chemicalControl: 'හානිය අධික නම් Thiamethoxam 25% WG හෝ Dinotefuran 20% SG හෝ Buprofezin යොදන්න.',
      imageAsset: 'assets/images/leaf_placeholder.jpg',
    ),

    // --- CUCURBITS (පිපිඤ්ඤා / වට්ටක්කා / කරවිල) ---
    PestDisease(
      id: 'p17',
      name: 'Cucurbit Fruit Fly (පළතුරු මැස්සා)',
      scientificName: 'Bactrocera cucurbitae',
      crop: 'Cucurbits (පිපිඤ්ඤා, වට්ටක්කා, කරවිල)',
      category: 'Insect Pest (කෘමියා)',
      symptoms: 'ගැහැණු මැස්සා ළපටි කරල් විද බිත්තර දැමීම නිසා ගෙඩිය ඇද වී දුඹුරු පැහැ ස්‍රාවයක් නිකුත් වීම. ඇතුළත පණුවන් බෝ වී කරල කුණු වී හැලී යාම.',
      prevention: 'ළපටි අවධියේදීම කරල් කඩදාසි හෝ පොලිතින් උරවලින් ආවරණය කිරීම (Fruit bagging). බිම වැටෙන සියලු රෝගී කරල් ගැඹුරු වළක වළලා දැමීම.',
      organicControl: 'මීතයිල් ඉයුජිනෝල් (Cue-lure) හෝ ප්‍රෝටීන් ඇම (Protein bait) සහිත උගුල් හෙක්ටයාරයකට 10-15ක් යෙදීම.',
      chemicalControl: 'ප්‍රෝටීන් බයිට් සමඟ Spinosad හෝ Malathion මිශ්‍ර කර කොළ යටි පැත්තට ඉසින්න.',
      imageAsset: 'assets/images/leaf_placeholder.jpg',
    ),

    // --- COCONUT (පොල්) ---
    PestDisease(
      id: 'p18',
      name: 'Red Palm Weevil (පොල් රතු කුරුමිණියා)',
      scientificName: 'Rhynchophorus ferrugineus',
      crop: 'Coconut (පොල්)',
      category: 'Insect Pest (කෘමියා)',
      symptoms: 'කඳ ඇතුළත ගුල් විදීම නිසා කඳෙන් දුඹුරු පැහැති දුම්මල වැනි ස්‍රාවයක් ගැලීම. කරටිය එක්පසකට නැමී මැරී යාම. කඳට කණ තැබූ විට පණුවන් දැව හපන ශබ්දය ඇසීම.',
      prevention: 'ළපටි පොල් ගස්වල (අවුරුදු 3-15) තුවාල ඇතිවීම වැළැක්වීම. තුවාල ඇති වුවහොත් තාර හෝ දිලීර නාශක ආලේප කිරීම.',
      organicControl: 'ෆෙරමෝන් උගුල් (Ferrolure+) වත්ත පුරා තැනින් තැන තබා ගැහැණු හා පිරිමි කුරුමිණියන් අල්ලා විනාශ කිරීම.',
      chemicalControl: 'හානි ලක්ෂණ පෙනෙන මුල් අවධියේදීම කඳේ සිදුරක් සාදා Imidacloprid හෝ Carbofuran කඳ තුළට එන්නත් කිරීම හෝ කරටිය පාමුලට දැමීම.',
      imageAsset: 'assets/images/leaf_placeholder.jpg',
    ),
  ];
}
