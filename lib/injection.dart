import 'package:connect_me_community_app/presentation/blocs/auth_cubit.dart';
import 'package:connect_me_community_app/services/auth_services.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

void setupDependencies() {
  sl.registerLazySingleton<AuthService>(AuthService.new);
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl<AuthService>()));
}
