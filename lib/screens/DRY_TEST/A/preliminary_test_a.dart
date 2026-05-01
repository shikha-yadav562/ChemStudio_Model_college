import 'package:chemstudio/DB/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:chemstudio/screens/DRY_TEST/A/dry_test_a.dart';

const Color primaryBlue = Color(0xFF004C91);
const Color accentTeal = Color(0xFF00A6A6);

class PreliminaryTestAScreen extends StatefulWidget {
  final int startIndex;
  final bool isReviewMode;
  final Map<int, String>? preliminaryAnswers;

  const PreliminaryTestAScreen({
    super.key,
    this.startIndex = 0,
    this.isReviewMode = false,
    this.preliminaryAnswers,
  });

  @override
  State<PreliminaryTestAScreen> createState() => _PreliminaryTestAScreenState();
}

class _PreliminaryTestAScreenState extends State<PreliminaryTestAScreen> {
  late int _index;
  final Map<int, String> _answers = {};
  final _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _index = widget.startIndex;

    if (widget.isReviewMode && widget.preliminaryAnswers != null) {
      _answers.addAll(widget.preliminaryAnswers!);
    }
  }

  final List<TestItem> _tests = [
    TestItem(
      id: 1,
      title: "1. Preliminary Test – Colour",
      observation: "Blue",
      options: [
        "Fe3+ may be present",
        "Cu2+ may be present",
        "Mn2+ may be present",
        "Co2+ may be present",
      ],
      correct: "Cu2+ may be present",
    ),
    TestItem(
      id: 2,
      title: "2. Nature Test – Solubility",
      observation: "Water Soluble",
      options: ["Crystalline", "Amorphous"],
      correct: "Crystalline",
    ),
  ];

  Future<void> _printPreliminaryAnswers() async {
    final answers = await _dbHelper.getAnswers('SaltA_PreliminaryTest');
    print('📘 --- Preliminary Test Answers from Database ---');
    for (var row in answers) {
      print(
        'Question ID: ${row['question_id']} | Answer: ${row['student_answer']}',
      );
    }
    print('----------------------------------------------');
  }

  void _next() async {
    if (_index < _tests.length - 1) {
      setState(() => _index++);
    } else {
      if (widget.isReviewMode) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DryTestAScreen(
              preliminaryAnswers: _answers,
              isReviewMode: true,
            ),
          ),
        );
      } else {
        await _printPreliminaryAnswers();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DryTestAScreen(preliminaryAnswers: _answers),
          ),
        );
      }
    }
  }

  void _prev() {
    if (_index > 0) setState(() => _index--);
  }

  @override
  Widget build(BuildContext context) {
    final test = _tests[_index];
    final selected = _answers[test.id];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        automaticallyImplyLeading: _index != 1,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [accentTeal, primaryBlue],
          ).createShader(bounds),
          child: Text(
            widget.isReviewMode
                ? "Salt A: Review Mode"
                : "Salt A: Preliminary Test",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              test.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildObservationCard(test),
                  const SizedBox(height: 24),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [accentTeal, primaryBlue],
                    ).createShader(bounds),
                    child: const Text(
                      'Based on the observation, select the correct inference:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...test.options.map((opt) {
                    final selectedHere = selected == opt;
                    final bool isCorrect = opt == test.correct;

                    Color borderColor;
                    Color backgroundColor;
                    Color textColor;

                    if (widget.isReviewMode) {
                      if (selectedHere && isCorrect) {
                        borderColor = Colors.green;
                        backgroundColor = Colors.green.withOpacity(0.1);
                        textColor = Colors.green;
                      } else if (selectedHere && !isCorrect) {
                        borderColor = Colors.red;
                        backgroundColor = Colors.red.withOpacity(0.1);
                        textColor = Colors.red;
                      } else if (!selectedHere && isCorrect) {
                        borderColor = Colors.green;
                        backgroundColor = Colors.green.withOpacity(0.05);
                        textColor = Colors.green.shade700;
                      } else {
                        borderColor = Colors.grey.shade300;
                        backgroundColor = Colors.white;
                        textColor = Colors.black87;
                      }
                    } else {
                      if (selectedHere) {
                        borderColor = accentTeal;
                        backgroundColor = accentTeal.withOpacity(0.1);
                        textColor = accentTeal;
                      } else {
                        borderColor = Colors.grey.shade300;
                        backgroundColor = Colors.white;
                        textColor = Colors.black87;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: InkWell(
                        onTap: widget.isReviewMode
                            ? null
                            : () async {
                                setState(() => _answers[test.id] = opt);

                                await _dbHelper.saveStudentAnswer(
                                  'SaltA_PreliminaryTest',
                                  test.id,
                                  opt,
                                );
                              },
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            border: Border.all(
                              color: borderColor,
                              width: widget.isReviewMode && isCorrect
                                  ? 2.5
                                  : 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  opt,
                                  style: TextStyle(
                                    fontWeight:
                                        (selectedHere ||
                                            (widget.isReviewMode && isCorrect))
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              if (widget.isReviewMode && selectedHere)
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: isCorrect ? Colors.green : Colors.red,
                                  size: 20,
                                ),
                              if (widget.isReviewMode &&
                                  !selectedHere &&
                                  isCorrect)
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: (_index == 0 && !widget.isReviewMode)
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.spaceBetween,
              children: [
                if (_index > 0 || widget.isReviewMode)
                  TextButton.icon(
                    onPressed: _index > 0 ? _prev : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Previous"),
                  ),
                ElevatedButton.icon(
                  onPressed: widget.isReviewMode
                      ? _next
                      : (selected != null ? _next : null),
                  icon: Icon(
                    _index == _tests.length - 1
                        ? Icons.check_circle_outline
                        : Icons.arrow_forward,
                  ),
                  label: Text(
                    _index == _tests.length - 1
                        ? "Proceed to Dry Test"
                        : "Next",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservationCard(TestItem test) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [accentTeal, primaryBlue],
              ).createShader(bounds),
              child: const Text(
                "Observation:",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (test.id == 1)
              _buildDarkBrownRectangle()
            else
              Row(
                children: [
                  const Icon(Icons.water_drop, color: accentTeal, size: 50),
                  const SizedBox(width: 10),
                  Text(
                    test.observation,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkBrownRectangle() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 37, 45, 100),
            Color.fromARGB(255, 24, 30, 101),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 45, 38, 124).withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "Blue",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class TestItem {
  final int id;
  final String title;
  final String observation;
  final List<String> options;
  final String correct;

  TestItem({
    required this.id,
    required this.title,
    required this.observation,
    required this.options,
    required this.correct,
  });
}
