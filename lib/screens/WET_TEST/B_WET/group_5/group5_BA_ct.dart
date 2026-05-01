// group5_ct_ba.dart
import 'package:chemstudio/DB/database_helper.dart';
import 'package:chemstudio/models/group_status.dart';
import 'package:chemstudio/screens/WET_TEST/B_WET/WetTestBFinalResultScreen.dart';
import 'package:chemstudio/screens/WET_TEST/B_WET/group0/group0analysis.dart';
import 'package:chemstudio/screens/WET_TEST/B_WET/group_6/group6_detection.dart';
import 'package:flutter/material.dart';

const Color primaryBlue = Color(0xFF004C91);
const Color accentTeal = Color(0xFF00A6A6);

class Group5CTBaScreen extends StatefulWidget {
  const Group5CTBaScreen({super.key});

  @override
  State<Group5CTBaScreen> createState() => _Group5CTBaScreenState();
}

class _Group5CTBaScreenState extends State<Group5CTBaScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedOption;
  bool get _isSelected => _selectedOption != null;

  late final AnimationController _animController;
  late final Animation<double> _fadeSlide;

  final _dbHelper = DatabaseHelper.instance;
  final String _tableName = 'SaltB_WetTest';

  late final WetTestItem _test = WetTestItem(
    id: 22, // Sequential ID
    title: 'C.T for Ba²⁺',
    procedure: 'Above acetate solution + dil. H₂SO₄',
    observation: 'White ppt',
    options: ['Ba²⁺ confirmed'],
    correct: 'Ba²⁺ confirmed',
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

  // ✅ Just select, don't navigate or save yet
  void _onOptionTapped(String option) {
    setState(() {
      _selectedOption = option;
    });
  }

  // ✅ Handle everything only when Next is clicked
  Future<void> _handleNext() async {
    if (_selectedOption == null) return;

    print('🔵 GROUP 5 CT BA - Starting _handleNext()');

    // 1️⃣ Save CT answer
    await _dbHelper.saveStudentAnswer(_tableName, _test.id, _selectedOption!);
    print('✅ Saved CT answer: $_selectedOption for question ID: ${_test.id}');

    // 2️⃣ Mark Group V as present
    await _dbHelper.insertGroupDecision(
      salt: 'B',
      groupNumber: 5,
      status: GroupStatus.present,
    );
    print('✅ Marked Group 5 as PRESENT');

    // 3️⃣ Count present groups
    final studentGroups = await _dbHelper.getStudentGroupDecisions('B');
    print('📊 All groups from DB: $studentGroups');

    final presentCount = studentGroups.values
        .where((status) => status == GroupStatus.present)
        .length;

    print('🔢 Present count: $presentCount');
    print(
      '🎯 Checking: presentCount ($presentCount) >= 2? ${presentCount >= 2}',
    );

    // 4️⃣ Navigate accordingly
    if (!mounted) return;

    if (presentCount >= 2) {
      print('✅ NAVIGATING TO RESULT SCREEN');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WetTestBFinalResultScreen(salt: 'B'),
        ),
      );
    } else {
      print('⚠️ NAVIGATING TO GROUP 6 DETECTION');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Group6Detection()),
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
        automaticallyImplyLeading: false,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [accentTeal, primaryBlue],
          ).createShader(bounds),
          child: const Text(
            'Salt B : Wet Test',
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
