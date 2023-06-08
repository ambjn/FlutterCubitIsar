import 'package:isar/isar.dart';
part 'post_collection.g.dart';

@Collection()
class PostCollection {
  String? title;
  String? body;
  Id? id;
}
