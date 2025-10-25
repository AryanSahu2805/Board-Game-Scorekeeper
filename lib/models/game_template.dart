class GameTemplate {
  final String name;
  final int startingScore;
  final String scoringMethod; // 'cumulative', 'per_round', 'first_to_target'
  final int? targetScore;
  final bool allowNegativeScores;

  GameTemplate({
    required this.name,
    required this.startingScore,
    required this.scoringMethod,
    this.targetScore,
    this.allowNegativeScores = false,
  });

  static List<GameTemplate> getDefaultTemplates() {
    return [
      GameTemplate(
        name: 'Catan',
        startingScore: 0,
        scoringMethod: 'first_to_target',
        targetScore: 10,
        allowNegativeScores: false,
      ),
      GameTemplate(
        name: 'Carcassonne',
        startingScore: 0,
        scoringMethod: 'cumulative',
        allowNegativeScores: false,
      ),
      GameTemplate(
        name: 'Terraforming Mars',
        startingScore: 20,
        scoringMethod: 'cumulative',
        allowNegativeScores: true,
      ),
      GameTemplate(
        name: 'Wingspan',
        startingScore: 0,
        scoringMethod: 'cumulative',
        allowNegativeScores: false,
      ),
      GameTemplate(
        name: 'Azul',
        startingScore: 0,
        scoringMethod: 'cumulative',
        allowNegativeScores: true,
      ),
      GameTemplate(
        name: 'Ticket to Ride',
        startingScore: 0,
        scoringMethod: 'cumulative',
        allowNegativeScores: false,
      ),
      GameTemplate(
        name: 'Splendor',
        startingScore: 0,
        scoringMethod: 'first_to_target',
        targetScore: 15,
        allowNegativeScores: false,
      ),
      GameTemplate(
        name: 'Scrabble',
        startingScore: 0,
        scoringMethod: 'cumulative',
        allowNegativeScores: false,
      ),
      GameTemplate(
        name: 'Uno',
        startingScore: 0,
        scoringMethod: 'first_to_target',
        targetScore: 500,
        allowNegativeScores: false,
      ),
      GameTemplate(
        name: 'Custom Game',
        startingScore: 0,
        scoringMethod: 'cumulative',
        allowNegativeScores: true,
      ),
    ];
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'startingScore': startingScore,
      'scoringMethod': scoringMethod,
      'targetScore': targetScore,
      'allowNegativeScores': allowNegativeScores ? 1 : 0,
    };
  }

  factory GameTemplate.fromMap(Map<String, dynamic> map) {
    return GameTemplate(
      name: map['name'],
      startingScore: map['startingScore'],
      scoringMethod: map['scoringMethod'],
      targetScore: map['targetScore'],
      allowNegativeScores: map['allowNegativeScores'] == 1,
    );
  }
}