class FertilizerLogic {
  // Common preset crops
  static const List<String> commonCrops = [
    'Paddy (වී)',
    'Corn (බඩඉරිඟු)',
    'Tomato (තක්කාලි)',
    'Chilli (මිරිස්)',
    'Big Onion (ලොකු ලූණු)',
    'Potato (අර්තාපල්)',
    'Carrot (කැරට්)',
    'Cabbage (ගෝවා)',
    'Brinjal (වම්බටු)',
    'Okra (බණ්ඩක්කා)',
    'Beans (බෝංචි)',
    'Banana (කෙසෙල්)',
    'Papaya (පැපොල්)',
    'Watermelon (කොමඩු)',
    'Pumpkin (වට්ටක්කා)',
    'Cucumber (පිපිඤ්ඤා)',
    'Bitter Gourd (කරවිල)',
    'Tea (තේ)',
    'Coconut (පොල්)',
    'Cinnamon (කුරුඳු)',
    'Other / Custom Crop (වෙනත් බෝගයක්)',
  ];

  // Returns a map with Urea, TSP, MOP amounts in kg
  static Map<String, double> calculateFertilizer(String crop, double acres) {
    final lower = crop.toLowerCase();

    if (lower.contains('paddy') || lower.contains('rice') || lower.contains('වී')) {
      return {
        'Urea (යුරියා)': 100.0 * acres,
        'TSP (මඩ පොහොර)': 25.0 * acres,
        'MOP (බන්ඩි පොහොර)': 30.0 * acres,
      };
    } else if (lower.contains('corn') || lower.contains('maize') || lower.contains('බඩඉරිඟු')) {
      return {
        'Urea (යුරියා)': 90.0 * acres,
        'TSP (මඩ පොහොර)': 40.0 * acres,
        'MOP (බන්ඩි පොහොර)': 35.0 * acres,
      };
    } else if (lower.contains('tomato') || lower.contains('තක්කාලි')) {
      return {
        'Urea (යුරියා)': 65.0 * acres,
        'TSP (මඩ පොහොර)': 50.0 * acres,
        'MOP (බන්ඩි පොහොර)': 45.0 * acres,
      };
    } else if (lower.contains('chilli') || lower.contains('chili') || lower.contains('pepper') || lower.contains('මිරිස්')) {
      return {
        'Urea (යුරියා)': 75.0 * acres,
        'TSP (මඩ පොහොර)': 60.0 * acres,
        'MOP (බන්ඩි පොහොර)': 50.0 * acres,
      };
    } else if (lower.contains('onion') || lower.contains('ලූණු') || lower.contains('ලූනු')) {
      return {
        'Urea (යුරියා)': 80.0 * acres,
        'TSP (මඩ පොහොර)': 70.0 * acres,
        'MOP (බන්ඩි පොහොර)': 50.0 * acres,
      };
    } else if (lower.contains('potato') || lower.contains('අර්තාපල්') || lower.contains('අල')) {
      return {
        'Urea (යුරියා)': 110.0 * acres,
        'TSP (මඩ පොහොර)': 110.0 * acres,
        'MOP (බන්ඩි පොහොර)': 85.0 * acres,
      };
    } else if (lower.contains('banana') || lower.contains('කෙසෙල්')) {
      return {
        'Urea (යුරියා)': 130.0 * acres,
        'TSP (මඩ පොහොර)': 65.0 * acres,
        'MOP (බන්ඩි පොහොර)': 150.0 * acres,
      };
    } else if (lower.contains('carrot') || lower.contains('කැරට්')) {
      return {
        'Urea (යුරියා)': 55.0 * acres,
        'TSP (මඩ පොහොර)': 65.0 * acres,
        'MOP (බන්ඩි පොහොර)': 60.0 * acres,
      };
    } else if (lower.contains('cabbage') || lower.contains('ගෝවා')) {
      return {
        'Urea (යුරියා)': 85.0 * acres,
        'TSP (මඩ පොහොර)': 75.0 * acres,
        'MOP (බන්ඩි පොහොර)': 60.0 * acres,
      };
    } else if (lower.contains('beans') || lower.contains('බෝංචි')) {
      return {
        'Urea (යුරියා)': 30.0 * acres,
        'TSP (මඩ පොහොර)': 50.0 * acres,
        'MOP (බන්ඩි පොහොර)': 35.0 * acres,
      };
    } else {
      return {
        'Urea (යුරියා)': 60.0 * acres,
        'TSP (මඩ පොහොර)': 45.0 * acres,
        'MOP (බන්ඩි පොහොර)': 40.0 * acres,
      };
    }
  }
}
