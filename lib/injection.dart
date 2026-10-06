import 'package:connect_me_community_app/data/datasources/firestore_post_datasource.dart';
import 'package:connect_me_community_app/data/datasources/local_post_datasource.dart';
import 'package:connect_me_community_app/data/repositories/post_repository_impl.dart';
import 'package:connect_me_community_app/domain/repositories/post_repository.dart';
import 'package:connect_me_community_app/domain/usecases/create_post.dart';
import 'package:connect_me_community_app/domain/usecases/get_posts.dart';
import 'package:connect_me_community_app/presentation/blocs/auth_cubit.dart';
import 'package:connect_me_community_app/presentation/blocs/post_cubit.dart';
import 'package:connect_me_community_app/services/auth_service.dart';
import 'package:connect_me_community_app/services/firestore_service.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  final preferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(preferences);

  // Services
  sl.registerLazySingleton<AuthService>(AuthService.new);
  sl.registerLazySingleton<FirestoreService>(FirestoreService.new);

  // Data sources
  sl.registerLazySingleton<FirestorePostDataSource>(
    () => FirestorePostDataSource(sl<FirestoreService>()),
  );
  sl.registerLazySingleton<LocalPostDataSource>(
    () => LocalPostDataSource(sl<SharedPreferences>()),
  );

  // Repository
  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(
      sl<FirestorePostDataSource>(),
      sl<LocalPostDataSource>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<GetPosts>(() => GetPosts(sl<PostRepository>()));
  sl.registerLazySingleton<CreatePost>(() => CreatePost(sl<PostRepository>()));

  // Cubits
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl<AuthService>()));
  sl.registerFactory<PostCubit>(
  () => PostCubit(sl<GetPosts>(), sl<CreatePost>(), sl<AuthService>()),
);
}