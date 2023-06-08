import 'package:bloc/bloc.dart';
import 'package:flutter_cubit_isar/data/models/post.dart';
import 'package:flutter_cubit_isar/data/repositories/posts_repository.dart';
import 'package:meta/meta.dart';

part 'posts_state.dart';

class PostsCubit extends Cubit<PostsState> {
  PostsCubit(this.postsRepository) : super(PostsInitial());

  int page = 1; // used to store current set of data
  final PostsRepository postsRepository;
  void loadPosts() {
    if (state is PostsLoading) return;
    final currentState = state;
    var oldPosts = <Post>[];
    if (currentState is PostsLoaded) {
      oldPosts = currentState.posts;
    }
    emit(PostsLoading(oldPosts, isFirstFetch: page == 1));
    postsRepository.fetchPosts(page).then((newPosts) {
      page++;
      final posts = (state as PostsLoading).oldPosts;
      posts.addAll(newPosts);
      emit(PostsLoaded(posts));
    });
  }
}
