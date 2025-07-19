class ContactUser {
  final String? name;
  final String? phone;
  final String? role;

  ContactUser({
    this.name,
    this.phone,
    this.role,
  });

  factory ContactUser.fromJson(Map<dynamic, dynamic> json) {
    return ContactUser(
      name: json['name'],
      phone: json['phone'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'phone': this.phone,
      'role': this.role,
    };
  }
}
