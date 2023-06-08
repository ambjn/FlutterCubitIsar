import 'package:flutter_cubit_isar/data/models/post.dart';
import 'package:flutter_cubit_isar/data/services/posts_service.dart';

class PostsRepository {
  final PostsService postsService;

  PostsRepository(this.postsService);
  Future<List<Post>> fetchPosts(int page) async {
    final posts = await postsService.fetchPosts(page);
    return posts.map((e) => Post.fromJson(e)).toList();
  }
}
