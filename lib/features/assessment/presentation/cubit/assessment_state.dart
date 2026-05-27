import '../../domain/entities/personality_profile.dart';

abstract class AssessmentState {}

class AssessmentInitial extends AssessmentState {}

class AssessmentCalculating extends AssessmentState {}

class AssessmentLoaded extends AssessmentState {
  final PersonalityProfile profile;
  AssessmentLoaded(this.profile);
}

class AssessmentError extends AssessmentState {
  final String message;
  AssessmentError(this.message);
}
