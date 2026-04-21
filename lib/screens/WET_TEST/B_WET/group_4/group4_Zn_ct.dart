import 'package:chemstudio/DB/database_helper.dart';
import 'package:chemstudio/models/group_status.dart';
import 'package:chemstudio/screens/WET_TEST/B_WET/WetTestBFinalResultScreen.dart';
import 'package:chemstudio/screens/WET_TEST/B_WET/b_intro.dart';
import 'package:chemstudio/screens/WET_TEST/B_WET/group0/group0analysis.dart';
import 'package:chemstudio/screens/WET_TEST/B_WET/group_5/group5_detection.dart';
import 'package:flutter/material.dart';

const Color primaryBlue = Color(0xFF004C91);
const Color accentTeal = Color(0xFF00A6A6);

class Zn2ConfirmedPage extends StatefulWidget {
  const Zn2ConfirmedPage({super.key});

  @override
  State<Zn2ConfirmedPage> createState() => _Zn2ConfirmedPageState();
}

class _Zn2ConfirmedPageState extends State<Zn2ConfirmedPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeSlide;

  String? _selectedOption;
  bool get _isSelected => _selectedOption != null;

  final _dbHelper = DatabaseHelper.instance;
  final String _tableName = 'SaltB_WetTest';

  final WetTestItem _test = WetTestItem(
    id: 19, // Unique ID for Zn²⁺ CT
    title: 'C.T For Zn²⁺',
    procedure: 'Above solution + NaOH',
    observation:
        'White ppt soluble in excess of NaOH, re-precipitated by passing H₂S gas',
    options: ['Zn²⁺ confirmed'],
    correct: 'Zn²⁺ confirmed',
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


  // ✅ Just select, don't save or navigate
  void _onOptionTapped(String option) {
    setState(() {
      _selectedOption = option;
    });
  }

  // ✅ Handle everything only when Next is clicked
  Future<void> _handleNext() async {
    if (_selectedOption == null) return;

    // 1️⃣ Save CT answer
    await _dbHelper.saveStudentAnswer(_tableName, _test.id, _selectedOption!);

    // 2️⃣ Mark Group 4 as present
    await _dbHelper.insertGroupDecision(
      salt: 'B',
      groupNumber: 4,
      status: GroupStatus.present,
    );

    // 3️⃣ Count present groups
    final groups = await _dbHelper.getStudentGroupDecisions('D');
    final presentCount = groups.values
        .where((status) => status == GroupStatus.present)
        .length;

    // 4️⃣ Navigate
    if (!mounted) return;

    if (presentCount >= 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WetTestBFinalResultScreen(salt: 'B'),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Group5DetectionScreen()),
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
              'Dissolve the white ppt in dilute HCl and remove H₂S gas by boiling. '
              'Use this solution for C.T.',
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

  Widget _buildTestCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGradientHeader('Test'),
            const SizedBox(height: 6),
            Text(_test.procedure, style: const TextStyle(fontSize: 15)),
            const Divider(height: 22),
            _buildGradientHeader('Observation'),
            const SizedBox(height: 6),
            Text(
              _test.observation,
              style: const TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 15,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryBlue),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const WetTestIntroBScreen()),
            (route) => false,
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
                      _buildTestCard(),
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
