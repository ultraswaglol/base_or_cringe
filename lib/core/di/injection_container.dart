import 'package:get_it/get_it.dart';
import '../../features/assessment/domain/usecases/calculate_personality_profile.dart';
import '../../features/assessment/presentation/cubit/assessment_cubit.dart';
import '../../features/game/data/datasources/game_local_data_source.dart';
import '../../features/game/data/repositories/game_repository_impl.dart';
import '../../features/game/domain/repositories/game_repository.dart';
import '../../features/game/presentation/bloc/game_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {

  sl.registerFactory(() => GameBloc(repository: sl()));
  sl.registerLazySingleton<GameRepository>(() => GameRepositoryImpl(localDataSource: sl()));
  sl.registerLazySingleton<GameLocalDataSource>(() => GameLocalDataSourceImpl());


  sl.registerFactory(() => AssessmentCubit(calculateProfile: sl()));
  sl.registerLazySingleton(() => CalculatePersonalityProfile());
}
