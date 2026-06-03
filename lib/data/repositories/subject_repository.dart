import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/exam_subject_group_model.dart';
import '../models/subject_model.dart';

class SubjectRepository {
  final ApiClient _client;
  SubjectRepository({required ApiClient client}) : _client = client;

  Future<List<SubjectModel>> getSubjectsByExam(int examId) async {
    final response =
        await _client.dio.get(ApiEndpoints.subjectsByExam(examId));
    final list =
        (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return list
        .map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SubjectModel> createSubject(Map<String, dynamic> data) async {
    final response =
        await _client.dio.post(ApiEndpoints.subjects, data: data);
    final body =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return SubjectModel.fromJson(body);
  }

  Future<List<ExamSubjectGroupModel>> getSubjectGroupsByExam(int examId) async {
    final response = await _client.dio.get(ApiEndpoints.subjectGroupsByExam(examId));
    final list = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return list
        .map((e) => ExamSubjectGroupModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ExamSubjectGroupModel> createSubjectGroup(Map<String, dynamic> data) async {
    final response = await _client.dio.post(ApiEndpoints.subjectGroups, data: data);
    final body = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ExamSubjectGroupModel.fromJson(body);
  }

  Future<ExamSubjectGroupModel> updateSubjectGroup(int groupId, Map<String, dynamic> data) async {
    final response = await _client.dio.put(ApiEndpoints.subjectGroupById(groupId), data: data);
    final body = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ExamSubjectGroupModel.fromJson(body);
  }

  Future<void> deleteSubjectGroup(int groupId) async {
    await _client.dio.delete(ApiEndpoints.subjectGroupById(groupId));
  }

  Future<SubjectModel> updateSubject(
      int id, Map<String, dynamic> data) async {
    final response =
        await _client.dio.put(ApiEndpoints.subjectById(id), data: data);
    final body =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return SubjectModel.fromJson(body);
  }

  Future<void> deleteSubject(int id, {required int examId}) async {
    await _client.dio.delete(
      ApiEndpoints.subjectById(id),
      queryParameters: {'examId': examId},
    );
  }

  Future<SubjectModel> cloneSubject({
    required int sourceSubjectId,
    required int targetExamId,
    int? displayOrder,
    bool? isActive,
    int? groupId,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.cloneSubject(sourceSubjectId),
      data: {
        'targetExamId': targetExamId,
        'displayOrder': displayOrder,
        'isActive': isActive,
        'groupId': groupId,
      },
    );
    final body =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return SubjectModel.fromJson(body);
  }
}
