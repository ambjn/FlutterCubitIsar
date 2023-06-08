import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cubit_isar/data/isar_db/collections/post_collection.dart';
import 'package:flutter_cubit_isar/data/repositories/posts_repository.dart';
import 'package:flutter_cubit_isar/data/services/posts_service.dart';
import 'package:flutter_cubit_isar/logic/cubit/posts_cubit.dart';
import 'package:flutter_cubit_isar/presentation/screens/posts_screen.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationSupportDirectory();
  if (dir.existsSync()) {
    final isar = await Isar.open([PostCollectionSchema], directory: dir.path);
    runApp(MainApp(
      postsRepository: PostsRepository(PostsService()),
      isar: isar,
    ));
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.postsRepository, required this.isar});
  final Isar isar;
  final PostsRepository postsRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Montserrat',
        ),
        home: BlocProvider(
          create: (context) => PostsCubit(postsRepository),
          child: PostsScreen(isar: isar),
        ));
  }
}
