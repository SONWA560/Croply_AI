import '../models/model_type.dart';

class TreatmentRecommendations {
  static String getRecommendation(String label, ModelType modelType) {
    switch (modelType) {
      case ModelType.diseaseDetection:
        return _getDiseaseRecommendation(label);
      case ModelType.pestDetection:
        return _getPestRecommendation(label);
      case ModelType.growthStage:
        return _getGrowthStageRecommendation(label);
    }
  }

  static String _getDiseaseRecommendation(String disease) {
    final String lower = disease.toLowerCase();

    // Pepper diseases
    if (lower.contains('pepper') && lower.contains('bacterial_spot')) {
      return '''
• Remove and destroy infected leaves immediately
• Apply copper-based bactericides every 7-10 days
• Avoid overhead watering to reduce leaf wetness
• Space plants properly for better air circulation
• Use disease-resistant varieties in future plantings
• Practice crop rotation with non-solanaceous crops
      ''';
    }
    if (lower.contains('pepper') && lower.contains('healthy')) {
      return '''
• Continue regular monitoring for early disease detection
• Maintain consistent watering schedule
• Apply balanced fertilizer as per soil test recommendations
• Keep garden area clean and free of plant debris
• Mulch around plants to regulate soil moisture
• Monitor for pest activity regularly
      ''';
    }

    // Potato diseases
    if (lower.contains('potato') && lower.contains('early_blight')) {
      return '''
• Apply fungicides containing chlorothalonil or mancozeb
• Remove lower leaves that touch the soil
• Practice crop rotation (3-4 year cycle)
• Water at soil level to keep foliage dry
• Destroy infected plant debris after harvest
• Use certified disease-free seed potatoes
      ''';
    }
    if (lower.contains('potato') && lower.contains('late_blight')) {
      return '''
URGENT ACTION REQUIRED - This disease spreads rapidly!

• Apply systemic fungicides immediately (metalaxyl or mefenoxam)
• Remove and destroy all infected plants
• Monitor weather - high humidity increases risk
• Improve air circulation around plants
• Avoid overhead irrigation completely
• Harvest tubers before foliage is completely dead
      ''';
    }
    if (lower.contains('potato') && lower.contains('healthy')) {
      return '''
• Maintain consistent soil moisture levels
• Apply balanced NPK fertilizer at planting
• Hill soil around plants as they grow
• Monitor for Colorado potato beetles and aphids
• Remove weeds that compete for nutrients
• Inspect plants weekly for early disease signs
      ''';
    }

    // Tomato diseases
    if (lower.contains('tomato') && lower.contains('bacterial_spot')) {
      return '''
• Apply copper-based sprays weekly during wet weather
• Remove and destroy severely infected leaves
• Disinfect tools between plants with 10% bleach solution
• Avoid working with plants when wet
• Improve drainage and reduce leaf wetness
• Use drip irrigation instead of overhead watering
      ''';
    }
    if (lower.contains('tomato') && lower.contains('early_blight')) {
      return '''
• Apply fungicides (chlorothalonil or copper-based) every 7-10 days
• Remove lower leaves up to first fruit cluster
• Mulch heavily to prevent soil splash
• Stake or cage plants for better air flow
• Water in morning so foliage dries quickly
• Rotate tomatoes to different location next year
      ''';
    }
    if (lower.contains('tomato') && lower.contains('late_blight')) {
      return '''
SEVERE THREAT - Act immediately!

• Apply fungicides containing chlorothalonil, mancozeb, or copper
• Remove all infected plant parts immediately
• Do not compost infected material - burn or bag
• Improve air circulation around plants
• Eliminate overhead watering completely
• Consider removing entire plants if heavily infected
      ''';
    }
    if (lower.contains('tomato') && lower.contains('leaf_mold')) {
      return '''
• Increase air circulation - prune excess foliage
• Reduce humidity around plants
• Apply sulfur or chlorothalonil-based fungicides
• Water at soil level only
• Remove infected leaves promptly
• Use resistant varieties in greenhouse settings
      ''';
    }
    if (lower.contains('tomato') && lower.contains('septoria_leaf_spot')) {
      return '''
• Apply fungicides containing copper or chlorothalonil
• Remove bottom leaves touching the soil
• Mulch around plants to prevent soil splash
• Space plants 24-36 inches apart
• Water early in day so leaves dry quickly
• Practice 3-year crop rotation
      ''';
    }
    if (lower.contains('tomato') && lower.contains('spider_mites')) {
      return '''
• Spray plants with strong water stream to dislodge mites
• Apply insecticidal soap or neem oil every 3-5 days
• Introduce predatory mites (Phytoseiulus persimilis)
• Maintain adequate plant hydration - stressed plants attract mites
• Remove heavily infested leaves
• Avoid broad-spectrum insecticides that kill beneficial insects
      ''';
    }
    if (lower.contains('tomato') && lower.contains('target_spot')) {
      return '''
• Apply fungicides containing chlorothalonil or mancozeb
• Remove infected leaves and fruit
• Improve air circulation by proper spacing
• Mulch to prevent soil splash
• Water at soil level only
• Rotate crops with non-solanaceous plants
      ''';
    }
    if (lower.contains('tomato') && lower.contains('yellow_leaf_curl')) {
      return '''
Viral disease - Focus on prevention and vector control!

• Remove infected plants immediately to prevent spread
• Control whiteflies (disease vector) with yellow sticky traps
• Apply neem oil or insecticidal soap for whiteflies
• Use reflective mulches to repel whiteflies
• Plant resistant varieties when available
• Use row covers on young plants
      ''';
    }
    if (lower.contains('tomato') && lower.contains('mosaic_virus')) {
      return '''
Viral disease - No cure available!

• Remove and destroy infected plants immediately
• Disinfect tools with 10% bleach solution between plants
• Wash hands thoroughly after handling tobacco products
• Control aphids (virus vector) with insecticidal soap
• Purchase only certified disease-free transplants
• Plant resistant varieties in future
      ''';
    }

    // Default for any unlisted diseases
    return '''
• Consult with local agricultural extension office for specific treatment
• Remove and destroy heavily infected plant parts
• Improve air circulation and reduce leaf wetness
• Apply appropriate fungicides or bactericides as recommended
• Practice good garden sanitation
• Monitor plants regularly for disease progression
    ''';
  }

  static String _getPestRecommendation(String pest) {
    final String lower = pest.toLowerCase();

    if (lower.contains('green') && lower.contains('leafhopper')) {
      return '''
• Apply neem oil or insecticidal soap weekly
• Use row covers on young plants
• Spray with pyrethrin-based insecticides if severe
• Remove weeds that harbor leafhoppers
• Encourage beneficial insects like ladybugs and lacewings
• Use yellow sticky traps to monitor populations
• Consider reflective mulches to deter leafhoppers
      ''';
    }
    if (lower.contains('aphid')) {
      return '''
• Spray plants with strong water stream daily
• Apply insecticidal soap or neem oil every 3-5 days
• Introduce beneficial insects (ladybugs, lacewings)
• Plant companion plants like marigolds and nasturtiums
• Use yellow sticky traps to monitor populations
• For severe infestations, use pyrethrin-based sprays
• Remove heavily infested plant parts
      ''';
    }
    if (lower.contains('armyworm')) {
      return '''
Can cause severe damage quickly!

• Apply Bacillus thuringiensis (Bt) in evening when larvae are active
• Use spinosad-based organic insecticides
• Hand-pick and destroy larvae when found
• Till soil in fall to expose pupae to cold
• Use pheromone traps to monitor adult moths
• Apply neem oil as a deterrent
• Encourage birds and beneficial insects
      ''';
    }
    if (lower.contains('beetle')) {
      return '''
• Hand-pick beetles into soapy water in early morning
• Apply neem oil or spinosad every 7 days
• Use floating row covers to protect plants
• Plant trap crops like radishes to lure beetles away
• Mulch heavily to prevent larvae from reaching soil
• Apply beneficial nematodes to soil for larvae control
• For severe cases, use pyrethrin-based sprays
      ''';
    }
    if (lower.contains('grasshopper')) {
      return '''
• Apply organic baits containing Nosema locustae
• Use floating row covers on vulnerable plants
• Create barriers with chicken wire or netting
• Use floating row covers on vulnerable plants
• Create barriers with chicken wire or netting
• Apply neem oil as a feeding deterrent
• Encourage natural predators (birds, praying mantis)
• Till soil in fall to destroy eggs
• For severe infestations, use pyrethrin sprays in early morning
      ''';
    }
    if (lower.contains('sawfly')) {
      return '''
• Hand-pick larvae (false caterpillars) from plants
• Spray with insecticidal soap or neem oil
• Apply spinosad for organic control
• Blast larvae off plants with strong water stream
• Remove and destroy heavily infested leaves
• Encourage parasitic wasps and birds
• Keep area clean of plant debris where they overwinter
      ''';
    }

    // Default pest recommendation
    return '''
• Identify the specific pest for targeted treatment
• Try mechanical removal (hand-picking) first
• Apply insecticidal soap or neem oil as first line of defense
• Introduce beneficial insects for biological control
• Use row covers to protect vulnerable plants
• Maintain plant health through proper watering and fertilization
• Consult local extension office for pest-specific advice
    ''';
  }

  static String _getGrowthStageRecommendation(String stage) {
    final String lower = stage.toLowerCase();

    if (lower.contains('germination')) {
      return '''
GERMINATION STAGE - Critical establishment period

• Maintain consistent soil moisture (not waterlogged)
• Ensure soil temperature is optimal for your crop (usually 65-75°F)
• Provide adequate light immediately after emergence
• Protect seedlings from extreme temperature fluctuations
• Avoid overwatering which can cause damping-off disease
• Do not fertilize until true leaves appear
• Thin seedlings if planted too densely

• Avoid overwatering which can cause damping-off disease
• Do not fertilize until true leaves appear
• Thin seedlings if planted too densely

Expected Timeline: 3-10 days depending on crop and conditions
      ''';
    }
    if (lower.contains('vegetative')) {
      return '''
VEGETATIVE STAGE - Focus on foliage development

• Apply nitrogen-rich fertilizer every 2-3 weeks
• Maintain consistent watering - 1-2 inches per week
• Mulch around plants to conserve moisture and suppress weeds
• Provide support structures (stakes, cages) before plants get too large
• Pinch growing tips to encourage bushier growth if desired
• Monitor closely for pest and disease issues
• Ensure adequate spacing for air circulation
• Side-dress with compost for sustained nutrient release

This stage focuses on building strong stems and healthy leaves
      ''';
    }
    if (lower.contains('flowering')) {
      return '''
FLOWERING STAGE - Transition to reproduction

• Switch to bloom fertilizer (higher phosphorus and potassium)
• Reduce nitrogen to avoid excess foliage at expense of flowers
• Maintain consistent watering - do not let plants stress
• Avoid overhead watering which can damage flowers
• Ensure good pollinator access - consider hand-pollination if needed
• Remove diseased flowers promptly to prevent spread
• Provide support for heavy fruit-bearing branches
• Monitor temperature - extreme heat can cause flower drop

Critical period for fruit set - consistent care is essential
      ''';
    }
    if (lower.contains('harvesting')) {
      return '''
HARVESTING STAGE - Reaping your rewards!

• Harvest in morning when plants are most hydrated
• Use clean, sharp tools to avoid spreading disease
• Pick regularly to encourage continued production
• Handle produce gently to avoid bruising
• Remove overripe or damaged fruit promptly
• Continue watering - don't let plants stress
• Reduce fertilization as harvest season winds down
• Monitor for pests attracted to ripening fruit

• Handle produce gently to avoid bruising
• Remove overripe or damaged fruit promptly
• Continue watering - don't let plants stress
• Reduce fertilization as harvest season winds down
• Monitor for pests attracted to ripening fruit

Storage Tips:
• Store at appropriate temperature for your crop
• Don't wash until ready to use
• Separate ethylene producers (tomatoes) from sensitive crops

Begin planning crop rotation for next season
      ''';
    }

    // Default growth stage recommendation
    return '''
• Monitor plant development daily
• Adjust watering based on weather and plant needs
• Fertilize according to growth stage requirements
• Watch for pest and disease issues
• Provide appropriate support structures
• Maintain consistent care practices
• Document observations for future reference
    ''';
  }
}
