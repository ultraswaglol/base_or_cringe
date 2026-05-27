import '../../domain/entities/situation.dart';

class SituationModel extends Situation {
  const SituationModel({
    required super.id,
    required super.text,
    required super.category,
    required super.stats,
    required super.comments,
    required super.baseTrait,
    required super.cringeTrait,
  });

  factory SituationModel.fromJson(Map<String, dynamic> json) {

    final commentsList = (json['comments'] as List)
        .map((c) => SocialComment(
              author: c['author'] ?? '',
              avatar: c['avatar'] ?? '',
              text: c['text'] ?? '',
            ))
        .toList();

    return SituationModel(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      category: _parseCategory(json['category']),
      stats: CommunityStats(
        baseVotes: json['baseVotes'] ?? 0,
        cringeVotes: json['cringeVotes'] ?? 0,
      ),
      baseTrait: _parseTrait(json['baseTrait']),
      cringeTrait: _parseTrait(json['cringeTrait']),
      comments: commentsList,
    );
  }

  static SituationCategory _parseCategory(String value) {
    switch (value) {
      case 'relationships':
        return SituationCategory.relationships;
      case 'lifestyle':
        return SituationCategory.lifestyle;
      case 'friendship':
        return SituationCategory.friendship;
      default:
        return SituationCategory.lifestyle;
    }
  }

  static PersonalityTrait _parseTrait(String value) {
    switch (value) {
      case 'sigma':
        return PersonalityTrait.sigma;
      case 'toxic':
        return PersonalityTrait.toxic;
      case 'pleaser':
        return PersonalityTrait.pleaser;
      default:
        return PersonalityTrait.sigma;
    }
  }
}
