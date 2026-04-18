import 'package:chemstudio/DB/database_helper.dart';
import 'package:chemstudio/screens/WET_TEST/C_WET/correct_answers.dart';
import 'package:flutter/material.dart';
import '../../welcome_screen.dart';
import 'package:chemstudio/screens/DRY_TEST/C/preliminary_test_c.dart';
import 'package:chemstudio/screens/WET_TEST/C_WET/c_intro.dart';
import 'package:chemstudio/screens/DRY_TEST/C/possible_radicals_c.dart';

const Color primaryBlue = Color(0xFF004C91);
const Color accentTeal = Color(0xFF00A6A6);

class DryTestCScreen extends StatefulWidget {
  final Map<int, String> preliminaryAnswers;
  final bool isReviewMode;
  final int startIndex; // Add this line

  const DryTestCScreen({
    super.key,
    required this.preliminaryAnswers,
    this.isReviewMode = false,
    this.startIndex = 0,
  });

  @override
  State<DryTestCScreen> createState() => _DryTestCScreenState();
}

class _DryTestCScreenState extends State<DryTestCScreen>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  final Map<int, String> _answers = {};
  late final AnimationController _animController;
  late final Animation<double> _fadeSlide;
  late final List<TestItem> _tests = _generateTests();

  final dbHelper = DatabaseHelper.instance;
  final String tableName = 'SaltC_DryTest';

  @override
  void initState() {
    super.initState();
    _index = widget.startIndex;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeSlide = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();

    _loadSavedAnswers();
    print("🧪 Preliminary Answers Received: ${widget.preliminaryAnswers}");
  }

  Future<void> _loadSavedAnswers() async {
    final data = await dbHelper.getAnswers(tableName);
    if (data.isNotEmpty) {
      setState(() {
        for (var row in data) {
          if (row['student_answer'] != null) {
            _answers[row['question_id']] = row['student_answer'];
          }
        }
      });
      print("🧪 Dry Test Answers Loaded: $_answers");
    }
  }

  static List<TestItem> _generateTests() {
    return [
      TestItem(
        id: 1,
        title: '1. Heating in a Dry Test Tube',
        procedure:
            'Take a small quantity of the mixture in a clean and dry test-tube and heat it strongly in an oxidising (blue) flame. Observe the change taking place.',
        observation: 'Coloured residue observed.\nCold: Brown\tHot: Black',
        options: ['Co2+', 'Cu2+', 'Fe3+', 'Pb2+'],
        correct: 'Fe3+',
      ),
      TestItem(
        id: 2,
        title: '2. NaOH Test',
        procedure:
            'Mix the salt with NaOH solution and heat gently. Hold moist turmeric paper near the mouth of the tube.',
        observation: 'Moist turmeric paper remains unchanged.',
        options: ['NH4+ Present', 'NH4+ Absent'],
        correct: 'NH4+ Absent',
      ),
      TestItem(
        id: 3,
        title: '3. Flame Test',
        procedure:
            'Prepare a paste of the salt with conc. HCl. Dip a platinum wire or glass rod in it and place it in an oxidising flame. Observe the colour.',
        observation: 'Apple-green flame observed.',
        options: [
          'Ca2+ may be present',
          'Ba2+ may be present',
          'Sr2+ may be present',
          'Pb2+ may be present',
          'Cu2+ may be present',
        ],
        correct: 'Ba2+ may be present',
      ),
    ];
  }

  Future<void> _saveAnswer(TestItem test, String selectedAnswer) async {
    await dbHelper.saveStudentAnswer(tableName, test.id, selectedAnswer);
    print("💾 Saved Dry Test Answer - Q${test.id}: $selectedAnswer");
  }

  void _next() async {
    if (_index < _tests.length - 1) {
      setState(() {
        _index++;
        _animController.forward(from: 0);
      });
    } else {
      if (widget.isReviewMode) {
        print("📊 Review Mode Complete - Dry Test Answers: $_answers");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SaltCResultScreen(
              userAnswers: _answers,
              tests: _tests,
              preliminaryAnswers: widget.preliminaryAnswers,
            ),
          ),
        );
      } else {
        await Future.delayed(const Duration(milliseconds: 200));
        print("🧪 Test Complete: Moving to Possible Radicals Selection");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PossibleRadicalsCScreen(
              userAnswers: _answers,
              tests: _tests,
              preliminaryAnswers: widget.preliminaryAnswers,
            ),
          ),
        );
      }
    }
  }

  void _prev() {
    if (_index == 0) {
      if (widget.isReviewMode) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SaltCResultScreen(
              userAnswers: _answers,
              tests: _tests,
              preliminaryAnswers: widget.preliminaryAnswers,
            ),
          ),
        );
      }
    } else {
      setState(() {
        _index--;
        _animController.forward(from: 0);
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [accentTeal, primaryBlue],
          ).createShader(bounds),
          child: Text(
            widget.isReviewMode ? 'Salt C : Review Mode' : 'Salt C : Dry Tests',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeSlide,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.1, 0.03),
            end: Offset.zero,
          ).animate(_fadeSlide),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  test.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: [
                      _buildTestCard(test),
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
                                : () {
                                    setState(() {
                                      _answers[test.id] = opt;
                                    });
                                    _saveAnswer(test, opt);
                                  },
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: borderColor,
                                  width: widget.isReviewMode && isCorrect
                                      ? 2.5
                                      : 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      opt,
                                      style: TextStyle(
                                        fontWeight:
                                            (selectedHere ||
                                                (widget.isReviewMode &&
                                                    isCorrect))
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                  if (widget.isReviewMode && selectedHere)
                                    Icon(
                                      isCorrect
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: isCorrect
                                          ? Colors.green
                                          : Colors.red,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _prev,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
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
                        _index == _tests.length - 1 ? 'Finish' : 'Next',
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
        ),
      ),
    );
  }

  Widget _buildTestCard(TestItem test) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _gradientHeader('Procedure'),
            const SizedBox(height: 4),
            Text(test.procedure, style: const TextStyle(fontSize: 14)),
            const Divider(height: 24),
            _gradientHeader('Observation'),
            const SizedBox(height: 8),
            if (test.id == 1) _heatingObservation(),
            if (test.id == 2) _naohObservation(test.observation),
            if (test.id == 3) _flameObservation(),
          ],
        ),
      ),
    );
  }

  Widget _gradientHeader(String text) => ShaderMask(
    shaderCallback: (bounds) => const LinearGradient(
      colors: [accentTeal, primaryBlue],
    ).createShader(bounds),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
  );

  Widget _heatingObservation() {
    return Column(
      children: [
        Text(
          'Coloured Residue',
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/pic_a.png',
                    height: 160,
                    errorBuilder: (_, __, ___) =>
                        const PlaceholderImage(label: 'Pic A (Hot : Black)'),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE6D8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '🔥 Hot : Black',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/pic_b.png',
                    height: 160,
                    errorBuilder: (_, __, ___) =>
                        const PlaceholderImage(label: 'Pic B (Cold : Brown)'),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 238, 220),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '❄️ Cold : Brown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color.fromARGB(255, 201, 101, 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _naohObservation(String observationText) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450, maxHeight: 250),
            child: Image.asset(
              'assets/images/turmeric_yellow.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const PlaceholderImage(label: 'Moist Turmeric Paper'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          observationText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _flameObservation() {
    return Center(
      child: Column(
        children: [
          Image.asset(
            'assets/images/flame_applegreen.png',
            height: 160,
            errorBuilder: (_, __, ___) =>
                const PlaceholderImage(label: 'flame_applegreen.png'),
          ),
          const SizedBox(height: 12),
          Text(
            'Apple Green flame',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Result Screen ----------
class SaltCResultScreen extends StatefulWidget {
  final Map<int, String> userAnswers;
  final List<TestItem> tests;
  final Map<int, String> preliminaryAnswers;

  const SaltCResultScreen({
    super.key,
    required this.userAnswers,
    required this.tests,
    required this.preliminaryAnswers,
  });

  @override
  State<SaltCResultScreen> createState() => _SaltCResultScreenState();
}

class _SaltCResultScreenState extends State<SaltCResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;

  Map<int, String> dryCorrect = {};
  Map<int, String> prelimCorrect = {};

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeCtrl.forward();

    dryCorrect = correctAnswers['SaltC_DryTest'] ?? {};
    prelimCorrect = correctAnswers['SaltC_PreliminaryTest'] ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [accentTeal, primaryBlue],
          ).createShader(bounds),
          child: const Text(
            'Salt C: Test Summary',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeCtrl,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Preliminary Test Answers:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView(
                  children: [
                    if (widget.preliminaryAnswers.isEmpty)
                      const Text(
                        'No preliminary test data found.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      )
                    else
                      ...widget.preliminaryAnswers.entries.map((entry) {
                        final correctAns =
                            prelimCorrect[entry.key] ?? 'Not found';
                        final isCorrect = entry.value == correctAns;

                        String title;
                        if (entry.key == 1) {
                          title = 'Preliminary Test: Colour';
                        } else if (entry.key == 2) {
                          title = 'Preliminary Test: Water Soluble';
                        } else {
                          title = 'Preliminary Test Q${entry.key}';
                        }

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [accentTeal, primaryBlue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              leading: Icon(
                                isCorrect ? Icons.check_circle : Icons.cancel,
                                color: isCorrect ? Colors.green : Colors.red,
                                size: 28,
                              ),
                              title: Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  'Your Answer: ${entry.value}\nCorrect Answer: $correctAns',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),

                    const SizedBox(height: 30),

                    const Text(
                      'Dry Test Answers:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...widget.tests.map((test) {
                      final ans =
                          widget.userAnswers[test.id] ?? 'No answer selected';
                      final correctAns = dryCorrect[test.id] ?? 'Not found';
                      final isCorrect = ans == correctAns;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [accentTeal, primaryBlue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            leading: Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? Colors.green : Colors.red,
                              size: 28,
                            ),
                            title: Text(
                              test.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                'Your Answer: $ans\nCorrect Answer: $correctAns',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: primaryBlue,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PreliminaryTestCScreen(
                                startIndex: 0,
                                isReviewMode: true,
                                preliminaryAnswers: widget.preliminaryAnswers,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.fact_check),
                        label: const Text(
                          "Recheck",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
  context,
  MaterialPageRoute(
    settings: const RouteSettings(name: '/c_intro'), // ✅ ADD THIS
    builder: (_) => WetTestIntroCScreen(
      userAnswers: widget.userAnswers,
      tests: widget.tests,
      preliminaryAnswers: widget.preliminaryAnswers,
    ),
  ),
);
                        },
                        icon: const Icon(Icons.science_rounded),
                        label: const Text(
                          "Start Wet Test ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentTeal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WelcomeScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.home_rounded),
                        label: const Text(
                          "Home",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TestItem {
  final int id;
  final String title;
  final String procedure;
  final String observation;
  final List<String> options;
  final String correct;

  TestItem({
    required this.id,
    required this.title,
    required this.procedure,
    required this.observation,
    required this.options,
    required this.correct,
  });
}

class PlaceholderImage extends StatelessWidget {
  final String label;
  const PlaceholderImage({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    );
  }
}
