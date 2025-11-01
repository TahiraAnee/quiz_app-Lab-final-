class Question {
  final String type;
  final String difficulty;
  final String category;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  final List<String> shuffledAnswers;

  Question({
    required this.type,
    required this.difficulty,
    required this.category,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
    required this.shuffledAnswers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final questionText = _decodeText(json['question']);
    final correctAnswerText = _decodeText(json['correct_answer']);
    final incorrectAnswersText = List<String>.from(json['incorrect_answers'])
        .map((answer) => _decodeText(answer))
        .toList();

    final allAnswers = [...incorrectAnswersText, correctAnswerText];
    allAnswers.shuffle();

    return Question(
      type: json['type'],
      difficulty: json['difficulty'],
      category: json['category'],
      question: questionText,
      correctAnswer: correctAnswerText,
      incorrectAnswers: incorrectAnswersText,
      shuffledAnswers: allAnswers,
    );
  }

  static String _decodeText(String text) {
    String decoded = text;
    
    if (decoded.contains('%')) {
      try {
        decoded = Uri.decodeComponent(decoded);
      } catch (e) {
        print('URL decoding failed: $e');
      }
    }
    
    decoded = decoded
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&eacute;', 'é')
        .replaceAll('&ouml;', 'ö')
        .replaceAll('&uuml;', 'ü');
    
    return decoded;
  }
}