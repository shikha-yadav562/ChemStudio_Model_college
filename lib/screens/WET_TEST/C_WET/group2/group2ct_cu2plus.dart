// group2ct_cu2plus.dart
import 'package:chemstudio/DB/database_helper.dart';
import 'package:chemstudio/models/group_status.dart';
import 'package:chemstudio/screens/WET_TEST/C_WET/WetTestCFinalResultScreen.dart';
import 'package:flutter/material.dart';
import '../group0/group0analysis.dart';
import '../group3/group3detection.dart';

const Color primaryBlue = Color(0xFF004C91);
const Color accentTeal = Color(0xFF00A6A6);

class WetTestCGroupTwoCTCuScreen extends StatefulWidget {
  const WetTestCGroupTwoCTCuScreen({super.key});

  @override
  State<WetTestCGroupTwoCTCuScreen> createState() =>
      _WetTestCGroupTwoCTCuScreenState();
}

class _WetTestCGroupTwoCTCuScreenState extends State<WetTestCGroupTwoCTCuScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedOption;
  bool get _isSelected => _selectedOption != null;

  late final AnimationController _animController;
  late final Animation<double> _fadeSlide;

  final _dbHelper = DatabaseHelper.instance;
  final String _tableName = 'SaltC_WetTest';

  late final WetTestItem _test = WetTestItem(
    id: 8,
    title: 'C.T for Cu²⁺',
    procedure: 'Above Solution + KI',
    observation: 'White ppt in brown coloured solution',
    options: ['Cu²⁺ confirmed'],
    correct: 'Cu²⁺ confirmed',
  );

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

  // ✅ FIXED: Just select, don't navigate or save yet
  void _onOptionTapped(String option) {
    setState(() {
      _selectedOption = option;
    });
  }

  // ✅ FIXED: Handle everything only when Next is clicked
  Future<void> _handleNext() async {
    if (_selectedOption == null) return;

    // 1️⃣ Save CT answer
    await _dbHelper.saveStudentAnswer(_tableName, _test.id, _selectedOption!);

    // 2️⃣ Mark Group II as present
    await _dbHelper.insertGroupDecision(
      salt: 'C',
      groupNumber: 2,
      status: GroupStatus.present,
    );

    // 3️⃣ Count present groups
    final studentGroups = await _dbHelper.getStudentGroupDecisions('C');
    final presentCount = studentGroups.values
        .where((status) => status == GroupStatus.present)
        .length;

    // 4️⃣ Navigate accordingly
    if (!mounted) return;

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
          builder: (_) => const WetTestCGroupThreeDetectionScreen(),
        ),
      );
    }
  }

  void _prev() {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget _buildGradientHeader(String text) {
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

  Widget _buildSolutionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGradientHeader('Solution'),
            const SizedBox(height: 6),
            const Text(
              'Dissolve the black ppt of group II in aquaregia (conc. HCL + conc. HNO3 in 3:1 proportion ), dilute with water. Use this solution for C.T of Cu2+',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(String procedure, String observation) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGradientHeader('Test'),
            const SizedBox(height: 4),
            Text(procedure, style: const TextStyle(fontSize: 14)),
            const Divider(height: 24),
            _buildGradientHeader('Observation'),
            const SizedBox(height: 8),
            Text(
              observation,
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
  Navigator.popUntil(context, (route) {
    return route.settings.name == '/c_intro';
  });
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
                      _buildSolutionCard(), // ✅ ADD THIS
                      const SizedBox(height: 12), // ✅ ADD THIS
                      _buildTestCard(_test.procedure, _test.observation),
                      const SizedBox(height: 24),
                      _buildGradientHeader('Select the correct inference:'),
                      const SizedBox(height: 10),
                      ..._test.options.map((opt) {
                        final selectedHere = _selectedOption == opt;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: InkWell(
                            onTap: () =>
                                _onOptionTapped(opt), // ✅ FIXED: Just select
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
                      }).toList(),
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
                          : null, // ✅ FIXED: Call _handleNext
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
}
