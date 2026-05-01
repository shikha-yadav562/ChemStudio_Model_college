// E:\flutter chemistry\wet\wet\lib\C\group2\group2detection.dart

import 'package:chemstudio/models/group_status.dart';
import 'package:flutter/material.dart';
import 'package:chemstudio/DB/database_helper.dart';
import '../group0/group0analysis.dart';
import 'group2analysis.dart'; // ✅ FIXED: Import correct analysis screen
import '../group3/group3detection.dart';

// --- Theme Constants ---
const Color primaryBlue = Color(0xFF004C91);
const Color accentTeal = Color(0xFF00A6A6);

class WetTestDGroupTwoDetectionScreen extends StatefulWidget {
  const WetTestDGroupTwoDetectionScreen({super.key});

  @override
  State<WetTestDGroupTwoDetectionScreen> createState() =>
      _WetTestDGroupTwoDetectionScreenState();
}

class _WetTestDGroupTwoDetectionScreenState
    extends State<WetTestDGroupTwoDetectionScreen>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  String? _selectedOption;

  late final AnimationController _animController;
  late final Animation<double> _fadeSlide;

  final _dbHelper = DatabaseHelper.instance;
  final String _tableName = 'SaltD_WetTest';

  late final List<WetTestItem> _tests = [
    WetTestItem(
      id: 6, // ✅ FIXED: Changed from 4 to 6 (correct sequential ID)
      title: 'Group II Detection',
      procedure: 'O.S/Filtrate + dil. HCL (heat) + H2S gas or water ',
      observation: 'No Black ppt',
      options: ['Group-II is present', 'Group-II is absent'],
      correct: 'Group-II is absent',
    ),
  ];

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
  /// Save ONLY detection answer
  Future<void> _onOptionSelected(WetTestItem test, String selected) async {
    setState(() => _selectedOption = selected);

    await _dbHelper.saveStudentAnswer(_tableName, test.id, selected);
  }

  // Replace the _next() method:
  void _next() async {
    if (_selectedOption == 'Group-II is present') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const WetTestDGroupTwoAnalysisScreen(),
        ),
      );
    } else if (_selectedOption == 'Group-II is absent') {
      await _dbHelper.clearGroupCTAnswers(_tableName, [8,9]);
      // ✅ ADD THIS: Mark Group 2 as absent before navigating
      await _dbHelper.insertGroupDecision(
        salt: 'D',
        groupNumber: 2,
        status: GroupStatus.absent,
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const WetTestDGroupThreeDetectionScreen(),
        ),
      );
    }
  }

  void _prev() {
    Navigator.pop(context, _selectedOption);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final test = _tests[_index];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [accentTeal, primaryBlue],
          ).createShader(bounds),
          child: const Text(
            'Salt D : Wet Test',
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
                      _buildInferenceHeader(),
                      const SizedBox(height: 10),
                      ...test.options.map((opt) {
                        final selectedHere = _selectedOption == opt;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: InkWell(
                            onTap: () async {
                              await _onOptionSelected(test, opt);
                            },
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
                      onPressed: _selectedOption != null ? _next : null,
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
        'Select the correct inference:',
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
