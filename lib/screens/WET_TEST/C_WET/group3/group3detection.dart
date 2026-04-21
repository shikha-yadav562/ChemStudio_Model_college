// E:\flutter chemistry\wet\wet\lib\C\group3\group3detection.dart
import 'package:chemstudio/DB/database_helper.dart';
import 'package:chemstudio/models/group_status.dart';
import 'package:chemstudio/screens/WET_TEST/C_WET/group_4/group4_detection.dart';
import 'package:flutter/material.dart';
import 'package:chemstudio/screens/WET_TEST/C_WET/group0/group0analysis.dart';
// DatabaseHelper, WetTestItem, etc.
import 'group3analysis.dart';

// --- Theme Constants ---
const Color primaryBlue = Color(0xFF004C91);
const Color accentTeal = Color(0xFF00A6A6);

// --- Placeholder for next screens (needed for compilation) ---
class WetTestCGroupFourDetectionScreen extends StatelessWidget {
  const WetTestCGroupFourDetectionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Group 4 Detection")),
      body: const Center(child: Text("Proceeding to Group IV Detection...")),
    );
  }
}

class WetTestCGroupThreeDetectionScreen extends StatefulWidget {
  const WetTestCGroupThreeDetectionScreen({super.key});

  @override
  State<WetTestCGroupThreeDetectionScreen> createState() =>
      _WetTestCGroupThreeDetectionScreenState();
}

class _WetTestCGroupThreeDetectionScreenState
    extends State<WetTestCGroupThreeDetectionScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedOption;

  late final AnimationController _animController;
  late final Animation<double> _fadeSlide;

  final _dbHelper = DatabaseHelper.instance;
  final String _tableName = 'SaltC_WetTest';

  late final WetTestItem _test = WetTestItem(
    id: 10,
    title: 'Group III Detection',
    procedure:
        'O.S/Filtrate (Remove H₂S) + NH₄Cl (equal) + NH₄OH ( till alkaline to litmus )',
    observation: 'White gelatineous ppt or reddish brown ppt',
    options: ['Group-III is present', 'Group-III is Absent'],
    correct: 'Group-III is present',
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

  // ✅ FIXED: Now properly assigns savedAnswer to _selectedOption

  Future<void> _onOptionSelected(WetTestItem test, String selected) async {
    setState(() {
      _selectedOption = selected;
    });

    await _dbHelper.saveStudentAnswer(_tableName, test.id, selected);
  }

  void _next() async {
    if (_selectedOption == 'Group-III is present') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const WetTestCGroupThreeAnalysisScreen(),
        ),
      );
    } else if (_selectedOption == 'Group-III is Absent') {
      await _dbHelper.clearGroupCTAnswers(_tableName, [12,13]);
      // ✅ ADD THIS: Mark Group 2 as absent before navigating
      await _dbHelper.insertGroupDecision(
        salt: 'C',
        groupNumber: 3,
        status: GroupStatus.absent,
      );

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Group4DetectionScreen()),
      );
    }
  }

  void _prev() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
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

  Widget _buildTestCard(WetTestItem test) {
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
            Text(test.procedure, style: const TextStyle(fontSize: 14)),
            const Divider(height: 24),
            _buildGradientHeader('Observation'),
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

  @override
  Widget build(BuildContext context) {
    final test = _test;

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
                      _buildGradientHeader('Select the correct inference:'),
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
}
