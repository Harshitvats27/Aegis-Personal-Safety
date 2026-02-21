class UserModel {
  String? name;
  String? id;
  String? phone;
  String? childEmail;
  String? guardianEmail;
  String? type;
  String? profilePic;

  UserModel({
    this.name,
    this.childEmail,
    this.id,
    this.guardianEmail,
    this.phone,
    this.profilePic,
    this.type,
  });

  /// Convert object → Firestore
  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'id': id,
    'childEmail': childEmail,
    'guardianEmail': guardianEmail, // fixed typo
    'type': type,
    'profilePic': profilePic,
    'createdAt': DateTime.now(),
  };

  /// Convert Firestore → object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      id: json['id'],
      phone: json['phone'],
      childEmail: json['childEmail'],
      guardianEmail: json['guardianEmail'],
      type: json['type'],
      profilePic: json['profilePic'],
    );
  }
}