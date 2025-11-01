import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../models/question.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuizProvider>(context, listen: false).loadPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        if (quizProvider.isLoading && quizProvider.questions.isEmpty) {
          return _buildConfigScreen(quizProvider);
        } else if (quizProvider.questions.isNotEmpty) {
          return _buildQuizScreen(quizProvider);
        } else {
          return _buildConfigScreen(quizProvider);
        }
      },
    );
  }

  Widget _buildConfigScreen(QuizProvider quizProvider) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Configuration'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfigItem(
              'Number of Questions',
              Slider(
                value: quizProvider.questionAmount.toDouble(),
                min: 1,
                max: 50,
                divisions: 49,
                label: quizProvider.questionAmount.toString(),
                onChanged: (value) {
                  quizProvider.setQuestionAmount(value.toInt());
                },
              ),
            ),
            _buildConfigItem(
              'Difficulty',
              DropdownButtonFormField<String>(
                value: quizProvider.difficulty,
                items: const [
                  DropdownMenuItem(value: 'any', child: Text('Any Difficulty')),
                  DropdownMenuItem(value: 'easy', child: Text('Easy')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'hard', child: Text('Hard')),
                ],
                onChanged: (value) {
                  quizProvider.setDifficulty(value!);
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            _buildConfigItem(
              'Question Type',
              DropdownButtonFormField<String>(
                value: quizProvider.type,
                items: const [
                  DropdownMenuItem(value: 'any', child: Text('Any Type')),
                  DropdownMenuItem(
                    value: 'multiple',
                    child: Text('Multiple Choice'),
                  ),
                  DropdownMenuItem(
                    value: 'boolean',
                    child: Text('True / False'),
                  ),
                ],
                onChanged: (value) {
                  quizProvider.setType(value!);
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const Spacer(),
            if (quizProvider.error.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  quizProvider.error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: quizProvider.isLoading
                    ? null
                    : () async {
                        await quizProvider.savePreferences();
                        quizProvider.startQuiz();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: quizProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        'Start Quiz',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigItem(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildQuizScreen(QuizProvider quizProvider) {
    final question = quizProvider.currentQuestion!;
    final isBoolean = question.type == 'boolean';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${quizProvider.currentQuestionIndex + 1}/${quizProvider.questions.length}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: (quizProvider.currentQuestionIndex + 1) /
                  quizProvider.questions.length,
              backgroundColor: Colors.grey.shade300,
              color: Colors.blue.shade600,
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                const Icon(Icons.timer, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${quizProvider.timeRemaining}s',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.category,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            if (isBoolean) _buildBooleanOptions(quizProvider, question),
            if (!isBoolean) _buildMultipleOptions(quizProvider, question),
            const Spacer(),
            if (quizProvider.answerSubmitted) _buildFeedback(quizProvider, question),
            if (!quizProvider.answerSubmitted && quizProvider.selectedAnswer != null)
              _buildSubmitButton(quizProvider),
            if (quizProvider.answerSubmitted) _buildNextButton(quizProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildBooleanOptions(QuizProvider quizProvider, Question question) {
    return Column(
      children: [
        _buildAnswerButton(
          quizProvider,
          'True',
          question.correctAnswer == 'True',
        ),
        const SizedBox(height: 12),
        _buildAnswerButton(
          quizProvider,
          'False',
          question.correctAnswer == 'False',
        ),
      ],
    );
  }

  Widget _buildMultipleOptions(QuizProvider quizProvider, Question question) {
    return Column(
      children: question.shuffledAnswers.map((answer) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildAnswerButton(
            quizProvider,
            answer,
            answer == question.correctAnswer,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnswerButton(
    QuizProvider quizProvider,
    String answer,
    bool isCorrect,
  ) {
    final isSelected = quizProvider.selectedAnswer == answer;
    Color backgroundColor = Colors.grey.shade100;
    Color borderColor = Colors.grey.shade300;
    Color textColor = Colors.black;

    if (quizProvider.answerSubmitted) {
      if (isCorrect) {
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green;
        textColor = Colors.green.shade800;
      } else if (isSelected) {
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red;
        textColor = Colors.red.shade800;
      }
    } else if (isSelected) {
      backgroundColor = Colors.blue.shade50;
      borderColor = Colors.blue;
      textColor = Colors.blue.shade800;
    }

    return OutlinedButton(
      onPressed: quizProvider.answerSubmitted
          ? null
          : () {
              quizProvider.selectAnswer(answer);
            },
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        side: BorderSide(color: borderColor, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          answer,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(QuizProvider quizProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          quizProvider.submitAnswer();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Submit Answer',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFeedback(QuizProvider quizProvider, Question question) {
    final isCorrect = quizProvider.selectedAnswer == question.correctAnswer;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
            border: Border.all(
              color: isCorrect ? Colors.green : Colors.red,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isCorrect ? 'Correct! Well done!' : 'Incorrect. The correct answer was: ${question.correctAnswer}',
                  style: TextStyle(
                    fontSize: 16,
                    color: isCorrect ? Colors.green.shade800 : Colors.red.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNextButton(QuizProvider quizProvider) {
    final isLastQuestion = quizProvider.currentQuestionIndex == quizProvider.questions.length - 1;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (isLastQuestion) {
            quizProvider.completeQuiz();
            Navigator.pushReplacementNamed(context, '/results');
          } else {
            quizProvider.nextQuestion();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          isLastQuestion ? 'See Results' : 'Next Question',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}