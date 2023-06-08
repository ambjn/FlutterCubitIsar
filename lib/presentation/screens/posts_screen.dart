import 'dart:async';
import 'dart:convert';
import 'package:flutter_cubit_isar/data/isar_db/collections/post_collection.dart';
import 'package:flutter_cubit_isar/logic/constants/constants.dart';
import 'package:flutter_cubit_isar/logic/cubit/posts_cubit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:flutter_cubit_isar/data/models/post.dart';

class PostsScreen extends StatefulWidget {
  final Isar isar;
  const PostsScreen({super.key, required this.isar});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final scrollController = ScrollController();
  bool isLocalDataDisplayed = true;
  @override
  void initState() {
    setupScrollController(context);
    super.initState();
  }

  void setupScrollController(context) {
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {
          BlocProvider.of<PostsCubit>(context).loadPosts();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    setupScrollController(context);
    BlocProvider.of<PostsCubit>(context).loadPosts();

    return Scaffold(
      appBar: AppBar(
        title: isLocalDataDisplayed
            ? GestureDetector(
                onTap: () async {
                  await widget.isar.writeTxn(() async {
                    await widget.isar.postCollections.clear();
                  });
                },
                child: const Text("Fetched From API"))
            : const Text("Fetched From ISAR DB"),
        backgroundColor:
            isLocalDataDisplayed ? Colors.redAccent : Colors.greenAccent,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isLocalDataDisplayed = !isLocalDataDisplayed;
              });
              storeApiResponeIsar();
            },
            icon: const Icon(
              Icons.change_circle_sharp,
              size: 35,
            ),
          )
        ],
      ),
      body: isLocalDataDisplayed ? postList() : postCardLocalB(),
    );
  }

  Widget postList() {
    return BlocBuilder<PostsCubit, PostsState>(builder: (context, state) {
      if (state is PostsLoading && state.isFirstFetch) {
        return loadingIndicator();
      }

      List<Post> posts = [];
      bool isLoading = false;

      if (state is PostsLoading) {
        posts = state.oldPosts;
        isLoading = true;
      } else if (state is PostsLoaded) {
        posts = state.posts;
      }

      return ListView.separated(
        controller: scrollController,
        itemBuilder: (context, index) {
          if (index < posts.length) {
            return post(posts[index], context);
          } else {
            Timer(const Duration(milliseconds: 30), () {
              scrollController
                  .jumpTo(scrollController.position.maxScrollExtent);
            });

            return loadingIndicator();
          }
        },
        separatorBuilder: (context, index) {
          return Divider(
            color: Colors.grey[400],
          );
        },
        itemCount: posts.length + (isLoading ? 1 : 0),
      );
    });
  }

  Widget loadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget post(Post post, BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      shadowColor: Colors.red.shade900,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${post.id.toString()}.',
                  style: const TextStyle(
                    overflow: TextOverflow.fade,
                    color: Colors.red,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                          overflow: TextOverflow.fade,
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(
              color: Colors.black12,
            ),
            const SizedBox(height: 10),
            Text(
              post.body,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget postCardLocalB() {
    return FutureBuilder<List<PostCollection>>(
        future: generatePosts(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.all(10),
                    shadowColor: Colors.green.shade900,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${snapshot.data![index].id!.toString()}.',
                                style: const TextStyle(
                                  overflow: TextOverflow.fade,
                                  color: Colors.green,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data![index].title!,
                                      style: const TextStyle(
                                        overflow: TextOverflow.fade,
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            color: Colors.black12,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            snapshot.data![index].body!,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return const SizedBox();
            }
          } else {
            return const SizedBox();
          }
        }));
  }

  void storeApiResponeIsar() async {
    final responses = await http.get(Uri.parse('$baseUrl/posts'));
    var responseData = json.decode(responses.body);
    List<Map<String, dynamic>> response = (responseData as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();

    await widget.isar.writeTxn(() async {
      await widget.isar.postCollections.clear();
      await widget.isar.postCollections.importJson(response);
    });
  }

  Future<List<PostCollection>> generatePosts() async {
    List<PostCollection> getPostCollection =
        await widget.isar.postCollections.where().findAll();
    return getPostCollection;
  }
}
