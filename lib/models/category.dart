class TriviaCategory {
  final int id;
  final String name;

  TriviaCategory({required this.id, required this.name});

  factory TriviaCategory.fromJson(Map<String, dynamic> json) {
    return TriviaCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}