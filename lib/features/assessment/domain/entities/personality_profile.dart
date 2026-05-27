enum ProfileType { sigma, toxic, pleaser }

class PersonalityProfile {
  final ProfileType type;
  final String title;
  final String emoji;
  final String description;
  final List<String> traits;
  final String recommendation;

  const PersonalityProfile({
    required this.type,
    required this.title,
    required this.emoji,
    required this.description,
    required this.traits,
    required this.recommendation,
  });
}
