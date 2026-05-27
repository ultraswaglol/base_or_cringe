import '../../../game/domain/entities/situation.dart';
import '../entities/personality_profile.dart';

class CalculatePersonalityProfile {
  PersonalityProfile call(List<Map<Situation, Choice>> history) {
    int sigmaPoints = 0;
    int toxicPoints = 0;
    int pleaserPoints = 0;

    for (final entry in history) {
      for (final mapEntry in entry.entries) {
        final situation = mapEntry.key;
        final choice = mapEntry.value;


        final trait = choice == Choice.base ? situation.baseTrait : situation.cringeTrait;

        switch (trait) {
          case PersonalityTrait.sigma:
            sigmaPoints++;
            break;
          case PersonalityTrait.toxic:
            toxicPoints++;
            break;
          case PersonalityTrait.pleaser:
            pleaserPoints++;
            break;
        }
      }
    }


    if (sigmaPoints >= toxicPoints && sigmaPoints >= pleaserPoints) {
      return _getSigmaProfile();
    } else if (toxicPoints >= pleaserPoints) {
      return _getToxicProfile();
    } else {
      return _getPleaserProfile();
    }
  }

  PersonalityProfile _getSigmaProfile() {
    return const PersonalityProfile(
      type: ProfileType.sigma,
      title: 'Абсолютный Сигма / Гигачад',
      emoji: '🗿',
      description: 'Твои личные границы крепки как сталь. Ты идеально распознаешь манипуляции, уважаешь правила социума, но не даешь ездить на своей шее. Абсолютная адекватность.',
      traits: [
        'Стальные личные границы',
        'Иммунитет к чувству вины',
        'Уважение к чужой свободе',
        'Прагматизм на максимуме',
      ],
      recommendation: 'Продолжай в том же духе. Ты опора этого общества. Главное — иногда снимай каменную маску и давай волю эмоциям.',
    );
  }

  PersonalityProfile _getToxicProfile() {
    return const PersonalityProfile(
      type: ProfileType.toxic,
      title: 'Душнила-Токсик / Душный Цензор',
      emoji: '☣️',
      description: 'Ты видишь «ред-флаги» даже там, где люди просто пытаются поздороваться. Иногда твои стандарты и ожидания от окружающих душат всё живое вокруг.',
      traits: [
        'Гиперчувствительность к мелочам',
        'Склонность к микроконтролю',
        'Душность в общении',
        'Тяжело идет на компромиссы',
      ],
      recommendation: 'Сделай глубокий вдох. Мир не идеален, и люди совершают ошибки. Попробуй проще относиться к мелким бытовым ситуациям, не всё в жизни — повод для суда.',
    );
  }

  PersonalityProfile _getPleaserProfile() {
    return const PersonalityProfile(
      type: ProfileType.pleaser,
      title: 'Угодник / Славный парень',
      emoji: '🥺',
      description: 'Ты готов терпеть жесткий кринж и нарушение своих границ, лишь бы никого не обидеть и остаться для всех «хорошим». Конфликты пугают тебя до дрожи.',
      traits: [
        'Синдром спасателя',
        'Страх сказать твердое "Нет"',
        'Задвигание себя на второй план',
        'Повышенная эмпатия',
      ],
      recommendation: 'Твоя доброта — суперсила, но без личных границ она превращается в слабость. Начни практиковать слово "Нет". Помни: защищать свои интересы — это нормально.',
    );
  }
}
