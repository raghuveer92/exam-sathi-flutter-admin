class AdminUserModel {
  final int id;
  final String email;
  final String fullName;
  final String? phone;
  final bool isActive;
  final String? selectedExamName;
  final int studyStreakDays;
  final List<String> roles;

  const AdminUserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.isActive = true,
    this.selectedExamName,
    this.studyStreakDays = 0,
    this.roles = const [],
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) => AdminUserModel(
        id: (json['id'] as num).toInt(),
        email: json['email'] as String,
        fullName: json['fullName'] as String,
        phone: json['phone'] as String?,
        isActive: (json['isActive'] as bool?) ?? true,
        selectedExamName: json['selectedExamName'] as String?,
        studyStreakDays: (json['studyStreakDays'] as num?)?.toInt() ?? 0,
        roles: (json['roles'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );

  bool get isAdmin => roles.contains('ROLE_ADMIN');
  String get firstName => fullName.split(' ').first;
}
