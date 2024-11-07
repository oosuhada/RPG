class TypeEffectiveness {
  static const Map<String, Map<String, double>> _effectivenessChart = {
    'Technology': {'Strength': 1.2, 'Speed': 0.8, 'Lightning': 1.0},
    'Strength': {'Speed': 1.2, 'Lightning': 0.8, 'Technology': 1.0},
    'Speed': {'Lightning': 1.2, 'Technology': 0.8, 'Strength': 1.0},
    'Lightning': {'Technology': 1.2, 'Strength': 0.8, 'Speed': 1.0},
  };

  static double getEffectiveness(String attackType, String defenderType) {
    if (_effectivenessChart.containsKey(attackType) &&
        _effectivenessChart[attackType]!.containsKey(defenderType)) {
      return _effectivenessChart[attackType]![defenderType]!;
    }
    return 1.0; // 기본 효과
  }
}
