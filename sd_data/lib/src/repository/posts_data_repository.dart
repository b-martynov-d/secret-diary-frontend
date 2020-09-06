import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sd_base/sd_base.dart';
import 'package:sddomain/core/error_handler.dart';
import 'package:sddomain/export/domain.dart';

class PostsDataRepository implements PostsRepository {
  final ErrorHandler _errorHandler;

  PostsDataRepository(this._errorHandler);

  @override
  Future<List<PostModel>> getFeedPostsBy(
      {String searchQuery,
      FeedSortType feedSortType,
      List<PostCategoryModel> postCategories,
      String fromPostId,
      int limit}) async {
    try {
      final databaseReference = FirebaseFirestore.instance;
      DocumentSnapshot lastDownloadedPostDoc;

      var orderByField;
      switch (feedSortType) {
        case FeedSortType.byDate:
          orderByField = FirestoreKeys.createdAtFieldKey;
          break;
        case FeedSortType.byCategories:
          orderByField = FirestoreKeys.createdAtFieldKey; // todo
          break;
        case FeedSortType.byComments:
          orderByField = FirestoreKeys.commentsFieldKey;
          break;
        case FeedSortType.byLikes:
          orderByField = FirestoreKeys.likesFieldKey;
          break;
      }

      if (fromPostId != null && fromPostId.isNotEmpty) {
        lastDownloadedPostDoc = await databaseReference
            .collection(FirestoreKeys.postsCollectionKey)
            .doc(fromPostId)
            .get();
      }

      var query = databaseReference
          .collection(FirestoreKeys.postsCollectionKey)
          .where(FirestoreKeys.visibilityFlagFieldKey, isEqualTo: true)
          .orderBy(orderByField, descending: true);

      if (lastDownloadedPostDoc != null) {
        query = query.startAfterDocument(lastDownloadedPostDoc);
      }
      final result = await query.limit(limit).get();

      final data = result.docs
          .map((postData) => PostModel.fromJson(
                id: postData.id,
                data: postData.data(),
              ))
          .toList();

      return data;
    } on dynamic catch (ex) {
      throw _errorHandler.handleNetworkError(ex);
    }
  }

  @override
  Future<PostModel> getPostById(String postId) async {
    try {
      final databaseReference = FirebaseFirestore.instance;

      final doc = await databaseReference
          .collection(FirestoreKeys.postsCollectionKey)
          .doc(postId)
          .get();

      return PostModel.fromJson(
        id: doc.id,
        data: doc.data(),
      );
    } on dynamic catch (ex) {
      throw _errorHandler.handleNetworkError(ex);
    }
  }

  @override
  Future<List<PostModel>> getPostsOfUser({
    String userUid,
    String fromPostId,
    int limit,
  }) async {
    try {
      final databaseReference = FirebaseFirestore.instance;
      DocumentSnapshot lastDownloadedPostDoc;

      if (fromPostId != null && fromPostId.isNotEmpty) {
        lastDownloadedPostDoc = await databaseReference
            .collection(FirestoreKeys.postsCollectionKey)
            .doc(fromPostId)
            .get();
      }

      var query = databaseReference
          .collection(FirestoreKeys.postsCollectionKey)
          .where(FirestoreKeys.authorIdFieldKey, isEqualTo: userUid)
          .orderBy(FirestoreKeys.createdAtFieldKey, descending: true);

      if (lastDownloadedPostDoc != null) {
        query = query.startAfterDocument(lastDownloadedPostDoc);
      }

      final result = await query.limit(limit).get();

      final data = result.docs
          .map((postData) => PostModel.fromJson(
                id: postData.id,
                data: postData.data(),
              ))
          .toList();
      return data;
    } on dynamic catch (ex) {
      throw _errorHandler.handleNetworkError(ex);
    }
  }

  @override
  Future<bool> removePostById({
    String postId,
  }) async {
    try {
      final databaseReference = FirebaseFirestore.instance;

      await databaseReference
          .collection(FirestoreKeys.postsCollectionKey)
          .doc(postId)
          .delete();

      return true;
    } on dynamic catch (ex) {
      throw _errorHandler.handleNetworkError(ex);
    }
  }

  @override
  Future<PostModel> updatePost(PostModel postModel) {
    // TODO: implement updatePost
    throw UnimplementedError();
  }

  @override
  Future<bool> createPost({
    String userUid,
    String title,
    String description,
    bool visibilityFlag,
    List<String> categoriesIds,
  }) async {
    try {
      final databaseReference = FirebaseFirestore.instance;

      await databaseReference.collection(FirestoreKeys.postsCollectionKey).add({
        FirestoreKeys.titleFieldKey: title,
        FirestoreKeys.descriptionFieldKey: description,
        FirestoreKeys.visibilityFlagFieldKey: visibilityFlag,
        FirestoreKeys.authorIdFieldKey: userUid,
        FirestoreKeys.createdAtFieldKey: FieldValue.serverTimestamp(),
      });

      return true;
    } on dynamic catch (ex) {
      throw _errorHandler.handleNetworkError(ex);
    }
  }
}
