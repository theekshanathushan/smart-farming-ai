class FertilizerLogic {
  // Returns a map with Urea, TSP, MOP amounts in kg
  static Map<String, double> calculateFertilizer(String crop, double acres) {
    // These are simplified standard approximations in kg per acre for demonstration.
    // In a real app, this would be highly specific to the region, soil type, and growth phase.
    switch (crop) {
      case 'Paddy (වී)':
        return {
          'Urea (යුරියා)': 90.0 * acres,
          'TSP (මඩ පොහොර)': 25.0 * acres,
          'MOP (බන්ඩි පොහොර)': 25.0 * acres,
        };
      case 'Corn (බඩඉරිඟු)':
        return {
          'Urea (යුරියා)': 60.0 * acres,
          'TSP (මඩ පොහොර)': 20.0 * acres,
          'MOP (බන්ඩි පොහොර)': 20.0 * acres,
        };
      case 'Tomato (තක්කාලි)':
        return {
          'Urea (යුරියා)': 45.0 * acres,
          'TSP (මඩ පොහොර)': 30.0 * acres,
          'MOP (බන්ඩි පොහොර)': 40.0 * acres,
        };
      default:
        return {
          'Urea (යුරියා)': 40.0 * acres,
          'TSP (මඩ පොහොර)': 15.0 * acres,
          'MOP (බන්ඩි පොහොර)': 15.0 * acres,
        };
    }
  }
}
