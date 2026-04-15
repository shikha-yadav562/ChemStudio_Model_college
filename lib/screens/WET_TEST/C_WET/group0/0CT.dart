import 'package:chemstudio/models/group_status.dart';
import 'package:chemstudio/screens/WET_TEST/C_WET/group1/group1detection.dart';
import 'package:chemstudio/screens/WET_TEST/C_WET/WetTestCFinalResultScreen.dart';
import 'package:flutter/material.dart';
import 'group0analysis.dart';
import '../c_intro.dart';
import 'package:chemstudio/DB/database_helper.dart';

const Color primaryBlue = Color(0xFF004C91);
const Color accentTeal = Color(0xFF00A6A6);

class WetTestCGroupZeroCTScreen extends StatefulWidget {
  const WetTestCGroupZeroCTScreen({super.key});

  @override
  State<WetTestCGroupZeroCTScreen> createState() =>
      _WetTestCGroupZeroCTScreenState();
}

class _WetTestCGroupZeroCTScreenState extends State<WetTestCGroupZeroCTScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeSlide;

  String? _selectedOption;
  bool get _isSelected => _selectedOption != null;

  final WetTestItem _test = WetTestItem(
    id: 2,
    title: 'C.T FOR NH₄⁺',
    procedure: 'O.S + Nessler’s reagent in excess',
    observation: 'Brown ppt/colouration of basic mercury (II) amidoiodine',
    options: ['NH₄⁺ Confirmed'],
    correct: 'NH₄⁺ Confirmed',
  );

  final _dbHelper = DatabaseHelper.instance;
  final String _tableName = 'SaltC_WetTest';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeSlide = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );

    _loadSavedAnswer();
    _animController.forward();
  }

  Future<void> _loadSavedAnswer() async {
    final studentAnswer = await _dbHelper.getStudentAnswer(
      _tableName,
      _test.id,
    );
    if (studentAnswer != null) {
      setState(() {
        _selectedOption = studentAnswer;
      });
    }
  }

  // ✅ FIXED: Just select, don't navigate
  void _onOptionTapped(String option) {
    setState(() {
      _selectedOption = option;
    });
  }

  // ✅ FIXED: Handle navigation only when Next is clicked
  Future<void> _handleNext() async {
    if (_selectedOption == null) return;

    // 1️⃣ Save CT answer
    await _dbHelper.saveStudentAnswer(_tableName, _test.id, _selectedOption!);

    // 2️⃣ Mark Group 0 as PRESENT
    await _dbHelper.insertGroupDecision(
      salt: 'C',
      groupNumber: 0,
      status: GroupStatus.present,
    );

    // 3️⃣ Check how many groups are PRESENT
    final groups = await _dbHelper.getStudentGroupDecisions('C');
    final presentCount = groups.values
        .where((status) => status == GroupStatus.present)
        .length;

    // 4️⃣ Navigate based on count
    if (presentCount >= 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WetTestCFinalResultScreen(salt: 'C'),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WetTestCGroupOneDetectionScreen(),
        ),
      );
    }
  }

  void _prev() => Navigator.pop(context);

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryBlue),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const WetTestIntroCScreen()),
              (route) => false,
            );
          },
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [accentTeal, primaryBlue],
          ).createShader(bounds),
          child: const Text(
            'Salt C : Wet Test',
            style: TextStyle(
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
                  _test.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: [
                      _buildTestCard(_test),
                      const SizedBox(height: 24),
                      _buildInferenceHeader(),
                      const SizedBox(height: 10),
                      ..._test.options.map((opt) {
                        final selectedHere = _selectedOption == opt;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: InkWell(
                            onTap: () => _onOptionTapped(opt), // ✅ Just select
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: selectedHere
                                    ? accentTeal.withOpacity(0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selectedHere
                                      ? accentTeal
                                      : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                opt,
                                style: TextStyle(
                                  fontWeight: selectedHere
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: selectedHere
                                      ? primaryBlue
                                      : Colors.black87,
                                ),
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
                      onPressed: _isSelected
                          ? _handleNext
                          : null, // ✅ Call _handleNext
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
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

  Widget _buildInferenceHeader() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [accentTeal, primaryBlue],
      ).createShader(bounds),
      child: const Text(
        'Result:',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTestCard(WetTestItem test) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _gradientHeader('Test'),
            const SizedBox(height: 4),
            Text(test.procedure, style: const TextStyle(fontSize: 14)),
            const Divider(height: 24),
            _gradientHeader('Observation'),
            const SizedBox(height: 8),
            Text(
              test.observation,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradientHeader(String text) {
    return ShaderMask(
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
  }
}
