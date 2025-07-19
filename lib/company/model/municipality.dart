class Municipality {
  final String name;

  Municipality({required this.name});

  factory Municipality.fromJson(Map<dynamic, dynamic> json) {
    return Municipality(
      name: json['name'],
    );
  }
}
