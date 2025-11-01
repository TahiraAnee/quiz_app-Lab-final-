import 'dart:async';
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/question.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<TriviaCategory> _categories = [];
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = false;
  String _error = '';
  int _selectedCategoryId = 0;
  int _questionAmount = 10;
  String _difficulty = 'any';
  String _type = 'any';
  int _timeRemaining = 30;
  Timer? _timer;
  String? _selectedAnswer;
  bool _answerSubmitted = false;
  List<int> _answerResults = [];

  List<TriviaCategory> get categories => _categories;
  List<Question> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get selectedCategoryId => _selectedCategoryId;
  int get questionAmount => _questionAmount;
  String get difficulty => _difficulty;
  String get type => _type;
  int get timeRemaining => _timeRemaining;
  String? get selectedAnswer => _selectedAnswer;
  bool get answerSubmitted => _answerSubmitted;
  List<int> get answerResults => _answerResults;

  Question? get currentQuestion => _currentQuestionIndex < _questions.length
      ? _questions[_currentQuestionIndex]
      : null;

  double get accuracy => _questions.isNotEmpty ? _score / _questions.length : 0;
  int get totalTime => _questions.length * 30 - _timeRemaining;

  Future<void> loadCategories() async {
    if (_categories.isNotEmpty) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _categories = await _apiService.getCategories();
    } catch (e) {
      _error = 'Failed to load categories: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(int categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setQuestionAmount(int amount) {
    _questionAmount = amount;
    notifyListeners();
  }

  void setDifficulty(String difficulty) {
    _difficulty = difficulty;
    notifyListeners();
  }

  void setType(String type) {
    _type = type;
    notifyListeners();
  }

  Future<void> startQuiz() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _questions = await _apiService.getQuestions(
        amount: _questionAmount,
        category: _selectedCategoryId,
        difficulty: _difficulty,
        type: _type,
      );

      _currentQuestionIndex = 0;
      _score = 0;
      _answerResults = List.filled(_questions.length, 2);
      _selectedAnswer = null;
      _answerSubmitted = false;
      _startTimer();
    } catch (e) {
      _error = 'Failed to load questions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startTimer() {
    _timeRemaining = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        _timeRemaining--;
        notifyListeners();
      } else {
        _handleTimeout();
      }
    });
  }

  void selectAnswer(String answer) {
    if (_answerSubmitted) return;

    _selectedAnswer = answer;
    notifyListeners();
  }

  void submitAnswer() {
    if (_selectedAnswer == null || _answerSubmitted) return;

    _answerSubmitted = true;
    _timer?.cancel();

    final isCorrect = _selectedAnswer == currentQuestion!.correctAnswer;
    if (isCorrect) {
      _score++;
      _answerResults[_currentQuestionIndex] = 1;
    } else {
      _answerResults[_currentQuestionIndex] = 0;
    }

    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _selectedAnswer = null;
      _answerSubmitted = false;
      _startTimer();
    }
    notifyListeners();
  }

  void _handleTimeout() {
    _timer?.cancel();
    _answerSubmitted = true;
    _answerResults[_currentQuestionIndex] = 0;
    notifyListeners();
  }

  void resetQuiz() {
    _timer?.cancel();
    _currentQuestionIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _answerSubmitted = false;
    _timeRemaining = 30;
    _answerResults = [];
    _questions.clear();
    _error = '';
    notifyListeners();
  }

  void completeQuiz() {
    _timer?.cancel();
    notifyListeners();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _questionAmount = prefs.getInt('questionAmount') ?? 10;
    _difficulty = prefs.getString('difficulty') ?? 'any';
    _type = prefs.getString('type') ?? 'any';
    notifyListeners();
  }

  Future<void> savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('questionAmount', _questionAmount);
    await prefs.setString('difficulty', _difficulty);
    await prefs.setString('type', _type);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
