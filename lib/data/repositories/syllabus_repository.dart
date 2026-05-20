import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/chapter_model.dart';
import '../models/topic_model.dart';

class SyllabusRepository {
  final ApiClient _client;
  SyllabusRepository({required ApiClient client}) : _client = client;

  // ── Chapters ─────────────────────────────────────────────────────────────

  Future<List<ChapterModel>> getChaptersBySubject(int subjectId) async {
    final res = await _client.dio.get(ApiEndpoints.chaptersBySubject(subjectId));
    final list = res.data['data'] as List<dynamic>;
    return list.map((e) => ChapterModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ChapterModel> createChapter(Map<String, dynamic> data) async {
    final res = await _client.dio.post(ApiEndpoints.createChapter, data: data);
    return ChapterModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<ChapterModel> updateChapter(int id, Map<String, dynamic> data) async {
    final res = await _client.dio.put(ApiEndpoints.updateChapter(id), data: data);
    return ChapterModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteChapter(int id) async {
    await _client.dio.delete(ApiEndpoints.deleteChapter(id));
  }

  // ── Topics ────────────────────────────────────────────────────────────────

  Future<List<TopicModel>> getTopicsByChapter(int chapterId) async {
    final res = await _client.dio.get(ApiEndpoints.topicsByChapter(chapterId));
    final list = res.data['data'] as List<dynamic>;
    return list.map((e) => TopicModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TopicModel> createTopic(Map<String, dynamic> data) async {
    final res = await _client.dio.post(ApiEndpoints.createTopic, data: data);
    return TopicModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<TopicModel> updateTopic(int id, Map<String, dynamic> data) async {
    final res = await _client.dio.put(ApiEndpoints.updateTopic(id), data: data);
    return TopicModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteTopic(int id) async {
    await _client.dio.delete(ApiEndpoints.deleteTopic(id));
  }
}
