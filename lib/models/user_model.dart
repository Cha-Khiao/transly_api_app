class User {
  final String uuid;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String? firstName;
  final String? lastName;

  User({
    required this.uuid,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.firstName,
    this.lastName,
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return name;
  }

  String get initials {
    final fn = firstName ?? '';
    final ln = lastName ?? '';
    final String firstNameInitial = fn.isNotEmpty ? fn[0] : '';
    final String lastNameInitial = ln.isNotEmpty ? ln[0] : '';

    if (firstNameInitial.isEmpty && lastNameInitial.isEmpty) {
      return name.isNotEmpty ? name[0].toUpperCase() : '?';
    }

    return '$firstNameInitial$lastNameInitial'.toUpperCase();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uuid: json['uuid'] ?? '',
      name: json['name'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'first_name': firstName,
      'last_name': lastName,
    };
  }
}
