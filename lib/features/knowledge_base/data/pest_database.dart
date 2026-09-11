class PestDisease {
  final String id;
  final String name;
  final String scientificName;
  final String symptoms;
  final String prevention;
  final String imageAsset;

  const PestDisease({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.symptoms,
    required this.prevention,
    required this.imageAsset,
  });
}

class PestDatabase {
  static const List<PestDisease> pests = [
    PestDisease(
      id: 'p1',
      name: 'Brown Plant Hopper (දුඹුරු පැළ කීඩෑවා)',
      scientificName: 'Nilaparvata lugens',
      symptoms: 'කොළ කහ පැහැ වී මැරී යයි. ගොයම් ගස වියළී යයි (Hopper burn).',
      prevention: 'ප්‍රතිරෝධී වී ප්‍රභේද භාවිතා කිරීම. නියමිත පරතරය තබා සිටුවීම. කෘමිනාශක නිසි ලෙස භාවිතය.',
      imageAsset: 'assets/images/leaf_placeholder.jpg', // Placeholder
    ),
    PestDisease(
      id: 'p2',
      name: 'Rice Blast (වී කොළ පාළුව)',
      scientificName: 'Magnaporthe oryzae',
      symptoms: 'කොළ මත දියමන්ති හැඩයේ ලප ඇතිවීම. කරල් මැරී යාම.',
      prevention: 'අධික නයිට්‍රජන් භාවිතයෙන් වැළකීම. රෝගයට ඔරොත්තු දෙන ප්‍රභේද භාවිතා කිරීම.',
      imageAsset: 'assets/images/leaf_placeholder.jpg',
    ),
    PestDisease(
      id: 'p3',
      name: 'Fall Armyworm (සේනා දළඹුවා)',
      scientificName: 'Spodoptera frugiperda',
      symptoms: 'බඩඉරිඟු කොළ කා දැමීම සහ සුදු පැහැති සලකුණු ඉතිරි කිරීම. ගොබය ඇතුළේ දළඹුවන් සිටීම.',
      prevention: 'කල් තියා වගා කිරීම. අළු ගැසීම හෝ නිර්දේශිත කෘමිනාශක යෙදීම.',
      imageAsset: 'assets/images/leaf_placeholder.jpg',
    ),
    PestDisease(
      id: 'p4',
      name: 'Tomato Blight (තක්කාලි අංගමාරය)',
      scientificName: 'Phytophthora infestans',
      symptoms: 'කොළ සහ ගෙඩි මත දුඹුරු පැහැති ලප ඇතිවීම. ශාකය ඉක්මනින් කුණු වී යාම.',
      prevention: 'හොඳ ජල වහනයක් පවත්වා ගැනීම. දිලීර නාශක භාවිතය. රෝගී ශාක කොටස් ඉවත් කිරීම.',
      imageAsset: 'assets/images/leaf_placeholder.jpg',
    ),
  ];
}
