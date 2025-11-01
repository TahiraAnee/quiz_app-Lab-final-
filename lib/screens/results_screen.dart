import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import 'welcome_screen.dart';
import 'category_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _isNavigating = false;

  // Function: Restart quiz and go to category screen
  void _playAgain(QuizProvider quizProvider) async {
    if (_isNavigating) return;

    setState(() => _isNavigating = true);

    try {
      quizProvider.resetQuiz();

      if (!mounted) return;

      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const CategoryScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isNavigating = false);
    }
  }

  // Function: Go to Welcome Screen
  void _goHome() async {
    if (_isNavigating) return;

    setState(() => _isNavigating = true);

    try {
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isNavigating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final score = quizProvider.score;
    final total = quizProvider.questions.length;
    final accuracy = quizProvider.accuracy;
    final totalTime = quizProvider.totalTime;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade800,
              Colors.purple.shade600,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Trophy Icon
                const Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: Colors.amber,
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Quiz Completed!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 32),

                // Score Summary Box
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$score/$total',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Final Score',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildStatItem(
                        'Accuracy',
                        '${(accuracy * 100).toStringAsFixed(1)}%',
                        Icons.flag,
                      ),
                      const SizedBox(height: 16),
                      _buildStatItem(
                        'Total Time',
                        '${totalTime ~/ 60}:${(totalTime % 60).toString().padLeft(2, '0')}',
                        Icons.timer,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Answer Summary
                _buildAnswerSummary(quizProvider),

                const Spacer(),

                // Play Again Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isNavigating ? null : () => _playAgain(quizProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade800,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 8,
                    ),
                    child: _isNavigating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.blue),
                            ),
                          )
                        : const Text(
                            'Play Again',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Go Home Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isNavigating ? null : _goHome,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Go to Home',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Statistic Item Widget
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // Answer Summary Widget
  Widget _buildAnswerSummary(QuizProvider quizProvider) {
    return Column(
      children: [
        const Text(
          'Answer Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(quizProvider.questions.length, (index) {
            final result = quizProvider.answerResults[index];
            Color color;
            IconData icon;

            if (result == 1) {
              color = Colors.green;
              icon = Icons.check;
            } else if (result == 0) {
              color = Colors.red;
              icon = Icons.close;
            } else {
              color = Colors.grey;
              icon = Icons.remove;
            }

            return Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: Colors.white,
              ),
            );
          }),
        ),
      ],
    );
  }
}
