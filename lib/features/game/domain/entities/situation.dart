enum SituationCategory {
  relationships,
  lifestyle,
  friendship,
}

enum Choice { base, cringe }


enum PersonalityTrait { sigma, toxic, pleaser }

class SocialComment {
  final String author;
  final String avatar;
  final String text;

  const SocialComment({
    required this.author,
    required this.avatar,
    required this.text,
  });
}

class CommunityStats {
  final int baseVotes;
  final int cringeVotes;

  const CommunityStats({
    required this.baseVotes,
    required this.cringeVotes,
  });

  double get basePercentage {
    final total = baseVotes + cringeVotes;
    if (total == 0) return 50.0;
    return (baseVotes / total) * 100;
  }

  double get cringePercentage => 100 - basePercentage;
}

class Situation {
  final String id;
  final String text;
  final SituationCategory category;
  final CommunityStats stats;
  final List<SocialComment> comments;


  final PersonalityTrait baseTrait;

  final PersonalityTrait cringeTrait;

  const Situation({
    required this.id,
    required this.text,
    required this.category,
    required this.stats,
    required this.comments,
    required this.baseTrait,
    required this.cringeTrait,
  });
}
