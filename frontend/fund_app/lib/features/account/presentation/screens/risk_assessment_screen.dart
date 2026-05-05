import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/account_provider.dart';

class RiskAssessmentScreen extends ConsumerStatefulWidget {
  const RiskAssessmentScreen({super.key});

  @override
  ConsumerState<RiskAssessmentScreen> createState() => _RiskAssessmentScreenState();
}

class _RiskAssessmentScreenState extends ConsumerState<RiskAssessmentScreen> {
  int _currentQuestion = 0;
  String? _selectedAnswer;
  final List<int> _answers = [];

  final List<Map<String, dynamic>> _questions = [
    {
      'question': '您的年龄范围是？',
      'options': ['18-30岁', '31-50岁', '51-65岁', '65岁以上'],
      'scores': <int>[10, 20, 30, 40],
    },
    {
      'question': '您的家庭年收入是？',
      'options': ['10万元以下', '10-50万元', '50-100万元', '100万元以上'],
      'scores': <int>[10, 20, 30, 40],
    },
    {
      'question': '您有多少投资经验？',
      'options': ['没有经验', '1-3年', '3-5年', '5年以上'],
      'scores': <int>[10, 20, 30, 40],
    },
    {
      'question': '您能接受多大的投资损失？',
      'options': ['不能接受任何损失', '5%以内', '5%-20%', '20%以上'],
      'scores': <int>[10, 20, 30, 40],
    },
    {
      'question': '您希望的投资回报周期是？',
      'options': ['短期（1年内）', '中期（1-3年）', '长期（3-5年）', '长期（5年以上）'],
      'scores': <int>[10, 20, 30, 40],
    },
  ];

  String _calculateRiskLevel(int totalScore) {
    if (totalScore <= 120) return 'C1';
    if (totalScore <= 160) return 'C2';
    if (totalScore <= 200) return 'C3';
    if (totalScore <= 240) return 'C4';
    return 'C5';
  }

  String _getRiskLevelDescription(String level) {
    switch (level) {
      case 'C1':
        return '保守型投资者，适合低风险产品';
      case 'C2':
        return '谨慎型投资者，适合中低风险产品';
      case 'C3':
        return '稳健型投资者，适合中等风险产品';
      case 'C4':
        return '积极型投资者，适合中高风险产品';
      case 'C5':
        return '激进型投资者，适合高风险产品';
      default:
        return '';
    }
  }

  Future<void> _submitAssessment() async {
    final totalScore = _answers.fold<int>(0, (sum, score) => sum + score);
    final level = _calculateRiskLevel(totalScore);

    final success = await ref.read(accountProvider.notifier).submitRiskAssessment(
      level: level,
      answers: _answers.map((e) => e.toString()).toList(),
    );

    if (success && mounted) {
      _showResultDialog(level);
    }
  }

  void _showResultDialog(String level) {
    final navigatorContext = context;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('风险评测结果'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('您的风险等级：$level', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_getRiskLevelDescription(level)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              navigatorContext.go('/');
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('风险评测'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: state.isLoading
          ? const LoadingWidget()
          : Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentQuestion + 1) / _questions.length,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '问题 ${_currentQuestion + 1}/${_questions.length}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _questions[_currentQuestion]['question'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        ...List.generate(
                          (_questions[_currentQuestion]['options'] as List).length,
                          (index) {
                            final option = _questions[_currentQuestion]['options'][index];
                            final score = _questions[_currentQuestion]['scores'][index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedAnswer = option;
                                    if (_answers.length > _currentQuestion) {
                                      _answers[_currentQuestion] = score;
                                    } else {
                                      _answers.add(score);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _selectedAnswer == option ? Colors.blue : Colors.grey[300]!,
                                      width: _selectedAnswer == option ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: _selectedAnswer == option ? Colors.blue[50] : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _selectedAnswer == option
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_off,
                                        color: _selectedAnswer == option ? Colors.blue : Colors.grey,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(option, style: const TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (_currentQuestion > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _currentQuestion--;
                                _selectedAnswer = _questions[_currentQuestion]['options'][
                                    _questions[_currentQuestion]['scores'].indexOf(_answers[_currentQuestion])];
                              });
                            },
                            child: const Text('上一题'),
                          ),
                        ),
                      if (_currentQuestion > 0) const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectedAnswer != null
                              ? () {
                                  if (_currentQuestion < _questions.length - 1) {
                                    setState(() {
                                      _currentQuestion++;
                                      _selectedAnswer = null;
                                    });
                                  } else {
                                    _submitAssessment();
                                  }
                                }
                              : null,
                          child: Text(_currentQuestion < _questions.length - 1 ? '下一题' : '提交'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}