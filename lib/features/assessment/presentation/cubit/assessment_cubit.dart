import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../game/domain/entities/situation.dart';
import '../../domain/usecases/calculate_personality_profile.dart';
import 'assessment_state.dart';

class AssessmentCubit extends Cubit<AssessmentState> {
  final CalculatePersonalityProfile calculateProfile;

  AssessmentCubit({required this.calculateProfile}) : super(AssessmentInitial());

  void processResults(List<Map<Situation, Choice>> history) {
    emit(AssessmentCalculating());



    Future.delayed(const Duration(milliseconds: 1500), () {
      try {
        final profile = calculateProfile(history);
        emit(AssessmentLoaded(profile));
      } catch (e) {
        emit(AssessmentError("Не удалось рассчитать психологический профиль. Попробуйте еще раз."));
      }
    });
  }
}
