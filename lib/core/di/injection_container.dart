import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../core/network/api_client.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/exam_repository.dart';
import '../../data/repositories/subject_repository.dart';
import '../../data/repositories/syllabus_repository.dart';
import '../../presentation/blocs/admin/admin_bloc.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/exam/exam_bloc.dart';
import '../../presentation/blocs/subject/subject_bloc.dart';

Future<void> setupDependencies() async {
  final sl = GetIt.I;

  sl.registerLazySingleton<Logger>(() => Logger());
  sl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());

  sl.registerLazySingleton<ApiClient>(() => ApiClient(
        storage: sl<FlutterSecureStorage>(),
        logger: sl<Logger>(),
      ));

  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepository(client: sl<ApiClient>()));
  sl.registerLazySingleton<AdminRepository>(
      () => AdminRepository(client: sl<ApiClient>()));
  sl.registerLazySingleton<ExamRepository>(
      () => ExamRepository(client: sl<ApiClient>()));
  sl.registerLazySingleton<SubjectRepository>(
      () => SubjectRepository(client: sl<ApiClient>()));
  sl.registerLazySingleton<SyllabusRepository>(
      () => SyllabusRepository(client: sl<ApiClient>()));

  sl.registerLazySingleton<AuthBloc>(
      () => AuthBloc(authRepository: sl<AuthRepository>()));
  sl.registerFactory<AdminBloc>(
      () => AdminBloc(repository: sl<AdminRepository>()));
  sl.registerFactory<ExamBloc>(
      () => ExamBloc(repository: sl<ExamRepository>()));
  sl.registerFactory<SubjectBloc>(
      () => SubjectBloc(repository: sl<SubjectRepository>()));
}
