// group5_ct_sr.dart
import 'package:chemstudio/DB/database_helper.dart';
import 'package:chemstudio/models/group_status.dart';
import 'package:chemstudio/screens/WET_TEST/A_WET/WetTestAFinalResultScreen.dart';
import 'package:flutter/material.dart';
import '../group0/group0analysis.dart';
import '../group_6/group6_detection.dart';
import '../a_intro.dart';

const Color primaryBlue = Color(0xFF004C91);
const Color accentTeal = Color(0xFF00A6A6);

class saltAGroup5CTSrScreen extends StatefulWidget {
  const saltAGroup5CTSrScreen({super.key});

  @override
  State<saltAGroup5CTSrScreen> createState() => _saltAGroup5CTSrScreenState();
}

class _saltAGroup5CTSrScreenState extends State<saltAGroup5CTSrScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedOption;
  bool get _isSelected => _selectedOption != null;

  late final AnimationController _animController;
  late final Animation<double> _fadeSlide;

  final _dbHelper = DatabaseHelper.instance;
  final String _tableName = 'SaltA_WetTest';

  late final WetTestItem _test = WetTestItem(
    id: 24, // Sequential ID
    title: 'C.T for Sr²⁺',
    procedure: 'Above acetate solution + dil. H₂SO₄',
    observation: 'White ppt on warming',
    options: ['Sr²⁺ confirmed'],
    correct: 'Sr²⁺ confirmed',
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
    _animController.forward();
  }

  // ✅ Just select, don't navigate
  void _onOptionTapped(String option) {
    setState(() {
      _selectedOption = option;
    });
  }

  // ✅ Handle navigation only when Next is clicked
  Future<void> _handleNext() async {
    if (_selectedOption == null) return;

    // 1️⃣ Save CT answer
    await _dbHelper.saveStudentAnswer(_tableName, _test.id, _selectedOption!);

    // 2️⃣ Mark Group V as present
    await _dbHelper.insertGroupDecision(
      salt: 'A',
      groupNumber: 5,
      status: GroupStatus.present,
    );

    // 3️⃣ Count present groups
    final studentGroups = await _dbHelper.getStudentGroupDecisions('A');
    final presentCount = studentGroups.values
        .where((status) => status == GroupStatus.present)
        .length;

    // 4️⃣ Navigate accordingly
    if (!mounted) return;

    if (presentCount >= 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WetTestAFinalResultScreen(salt: 'A'),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const saltAGroup6Detection()),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGradientHeader('Solution'),
            const SizedBox(height: 8),
            Text(
              'Dissolve the white ppt in hot acetic acid and use this (acetate) solution for further tests',
              style: TextStyle(
                fontSize: 14,
                color: primaryBlue,
                fontWeight: FontWeight.bold,
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
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const WetTestIntroAScreen()),
            (route) => false,
          ),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [accentTeal, primaryBlue],
          ).createShader(bounds),
          child: Text(
            'Salt A : Wet Test',
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
                      _buildSolutionCard(),
                      const SizedBox(height: 12),
                      _buildTestCard(_test.procedure, _test.observation),
                      const SizedBox(height: 24),
                      _buildGradientHeader('Select the correct inference:'),
                      const SizedBox(height: 10),
                      ..._test.options.map((opt) {
                        final selectedHere = _selectedOption == opt;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: InkWell(
                            onTap: () => _onOptionTapped(opt),
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
                                      ? accentTeal
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
                      onPressed: _isSelected ? _handleNext : null,
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
