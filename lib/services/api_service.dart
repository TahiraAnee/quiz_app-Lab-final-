import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/question.dart';

class ApiService {
  static const String baseUrl = 'https://opentdb.com';
  
  Future<List<TriviaCategory>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/api_category.php'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final categories = List<Map<String, dynamic>>.from(data['trivia_categories'])
          .map((json) => TriviaCategory.fromJson(json))
          .toList();
      return categories;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Question>> getQuestions({
    required int amount,
    required int category,
    required String difficulty,
    required String type,
  }) async {
    final params = {
      'amount': amount.toString(),
      'category': category.toString(),
    };
    
    if (difficulty != 'any') {
      params['difficulty'] = difficulty;
    }
    
    if (type != 'any') {
      params['type'] = type;
    }

    final uri = Uri.parse('$baseUrl/api.php').replace(queryParameters: params);
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['response_code'] == 0) {
        final questions = List<Map<String, dynamic>>.from(data['results'])
            .map((json) => Question.fromJson(json))
            .toList();
        return questions;
      } else {
        throw Exception('No results found');
      }
    } else {
      throw Exception('Failed to load questions');
    }
  }
}