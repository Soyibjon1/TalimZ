import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String subject;
  const QuizScreen({super.key, required this.subject});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<QuizQuestion> _questions;
  late final QuizProvider _quizProv;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _questions = MockData.mathQuiz;
    _quizProv = QuizProvider(
      questions: _questions,
      subject: widget.subject,
      topic: 'Trigonometriya asoslari',
    );
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _quizProv.tick();
      if (_quizProv.answered && !_quizProv.isLast) {
        // keep timer running for display
      }
    });
  }

  void _onAnswerSelected(int index) {
    _quizProv.selectAnswer(index);
    setState(() {});
  }

  void _onNext() {
    final hasMore = _quizProv.nextQuestion();
    if (!hasMore) {
      _finishQuiz();
    } else {
      setState(() {});
    }
  }

  void _finishQuiz() {
    _timer?.cancel();
    final result = _quizProv.buildResult();
    context.read<AppProvider>().recordQuizResult(result);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => QuizResultScreen(result: result)),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _quizProv,
      child: Consumer<QuizProvider>(
        builder: (context, quiz, _) {
          final q = quiz.currentQuestion;
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(quiz),
                  _buildProgressRow(quiz),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildTimerRow(quiz),
                          const SizedBox(height: 12),
                          _buildQuestionCard(q)
                              .animate(key: ValueKey(quiz.currentIndex))
                              .fadeIn(duration: 300.ms)
                              .slideY(begin: 0.05, end: 0),
                          const SizedBox(height: 14),
                          ...List.generate(q.options.length, (i) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _buildOption(quiz, q, i)
                                  .animate(delay: (i * 60).ms)
                                  .fadeIn(duration: 250.ms)
                                  .slideX(begin: 0.05, end: 0),
                            );
                          }),
                          if (quiz.answered) ...[
                            const SizedBox(height: 4),
                            _buildExplanation(q),
                            const SizedBox(height: 12),
                            _buildNextButton(quiz),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(QuizProvider quiz) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 24),
            color: AppColors.onSurface,
            onPressed: () {
              _timer?.cancel();
              context.pop();
            },
          ),
          Expanded(
            child: Text(widget.subject,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                )),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text('${quiz.totalXp} XP',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(QuizProvider quiz) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Text('${quiz.currentIndex + 1} / ${_questions.length} Savol',
                  style: AppTextStyles.labelSm),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: quiz.progress,
                    minHeight: 7,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryContainer),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${(quiz.progress * 100).round()}% Tamomlandi',
                  style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.primaryContainer)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerRow(QuizProvider quiz) {
    final isLow = quiz.timeLeft <= 10;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isLow
                  ? AppColors.error
                  : AppColors.outlineVariant,
              width: 2.5,
            ),
            color: isLow
                ? AppColors.error.withValues(alpha: 0.06)
                : Colors.transparent,
          ),
          child: Center(
            child: Text('${quiz.timeLeft}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isLow ? AppColors.error : AppColors.onSurface,
                )),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(QuizQuestion q) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Text(q.topic,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppColors.onSurfaceVariant,
              )),
          const SizedBox(height: 14),
          Text(q.question,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMd),
          const SizedBox(height: 18),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('Σ',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 30,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(QuizProvider quiz, QuizQuestion q, int i) {
    final label = String.fromCharCode(65 + i);
    final isSelected = quiz.selectedAnswer == i;
    final isCorrect = quiz.answered && i == q.correctIndex;
    final isWrong = quiz.answered && isSelected && i != q.correctIndex;

    Color borderColor = AppColors.outlineVariant;
    Color bgColor = AppColors.surfaceContainerLowest;
    Color textColor = AppColors.onSurface;
    Color labelBg = AppColors.surfaceContainerHigh;
    Color labelText = AppColors.onSurfaceVariant;

    if (isCorrect) {
      borderColor = AppColors.secondary;
      bgColor = AppColors.secondary.withValues(alpha: 0.06);
      textColor = AppColors.secondary;
      labelBg = AppColors.secondary;
      labelText = Colors.white;
    } else if (isWrong) {
      borderColor = AppColors.error;
      bgColor = AppColors.errorContainer.withValues(alpha: 0.25);
      textColor = AppColors.error;
      labelBg = AppColors.error;
      labelText = Colors.white;
    } else if (isSelected) {
      borderColor = AppColors.primary;
      bgColor = AppColors.primary.withValues(alpha: 0.05);
      textColor = AppColors.primary;
      labelBg = AppColors.primary;
      labelText = Colors.white;
    }

    return GestureDetector(
      onTap: () => _onAnswerSelected(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: borderColor, width: (isSelected || isCorrect) ? 2 : 1),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: labelBg, shape: BoxShape.circle),
              child: Center(
                child: Text(label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: labelText,
                    )),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(q.options[i],
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  )),
            ),
            if (isCorrect)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.secondary, size: 20),
            if (isWrong)
              const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanation(QuizQuestion q) {
    final isCorrect = _quizProv.selectedAnswer == q.correctIndex;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isCorrect ? AppColors.secondary : AppColors.error)
            .withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isCorrect ? AppColors.secondary : AppColors.error)
              .withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isCorrect ? '✅' : '❌', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect
                      ? 'To\'g\'ri javob!'
                      : 'Noto\'g\'ri. To\'g\'ri javob: ${q.options[q.correctIndex]}',
                  style: AppTextStyles.labelMd.copyWith(
                    color: isCorrect ? AppColors.secondary : AppColors.error,
                  ),
                ),
                if (q.explanation.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(q.explanation, style: AppTextStyles.bodySm),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildNextButton(QuizProvider quiz) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          if (quiz.isLast) {
            _finishQuiz();
          } else {
            _onNext();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              quiz.isLast ? 'Natijani ko\'rish' : 'Keyingisi',
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
