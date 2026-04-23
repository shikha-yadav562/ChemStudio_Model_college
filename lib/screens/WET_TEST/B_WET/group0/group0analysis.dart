import 'package:chemstudio/models/group_status.dart';
import 'package:flutter/material.dart';
import 'package:chemstudio/DB/database_helper.dart';
import '0CT.dart';
import 'package:chemstudio/screens/WET_TEST/B_WET/group1/group1detection.dart';
import '../b_intro.dart';

const Color primaryBlue = Color(0xFF004C91);
const Color accentTeal = Color(0xFF00A6A6);

// ---------------- Wet Test Item Model ----------------
class WetTestItem {
  final int id;
  final String title;
  final String procedure;
  final String observation;
  final List<String> options;

  /// ✅ REQUIRED for CT & result verification
  final String correct;

  WetTestItem({
    required this.id,
    required this.title,
    required this.procedure,
    required this.observation,
    required this.options,
    required this.correct,
  });
}

// ---------------- Group Zero Analysis Screen ----------------
class WetTestBGroupZeroScreen extends StatefulWidget {
  const WetTestBGroupZeroScreen({super.key});

  @override
  State<WetTestBGroupZeroScreen> createState() =>
      _WetTestBGroupZeroScreenState();
}

class _WetTestBGroupZeroScreenState extends State<WetTestBGroupZeroScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedOption;

  late final AnimationController _animController;
  late final Animation<double> _fadeSlide;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final String _tableName = 'SaltB_WetTest';

  final WetTestItem _test = WetTestItem(
    id: 1,
    title: 'Analysis of Group Zero',
    procedure:
        'Take Original Solution (O.S.) in a test tube, add NaOH solution, and heat gently. Hold moist turmeric paper near the mouth of the test tube.',
    observation:
        ' Evolution of NH3 gas , which turns moist turmeric paper brown / red ',
    options: ['Group Zero is present', 'Group Zero is absent'],
    correct: 'Group Zero is present',
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

  Future<void> _onOptionSelected(String option) async {
    setState(() => _selectedOption = option);

    // ✅ ONLY save student answer
    await _dbHelper.saveStudentAnswer(_tableName, _test.id, option);
  }

  void _next() async {
    // ✅ Add async
    if (_selectedOption == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an option')));
      return;
    }

    if (_selectedOption == 'Group Zero is present') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WetTestBGroupZeroCTScreen()),
      );
    } else {
      await _dbHelper.clearGroupCTAnswers(_tableName, [2]);
      // ✅ Mark Group 0 as absent before navigating
      await _dbHelper.insertGroupDecision(
        salt: 'B',
        groupNumber: 0,
        status: GroupStatus.absent,
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const WetTestBGroupOneDetectionScreen(),
        ),
      );
    }
  }

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
                    _buildTestCard(),
                    const SizedBox(height: 24),
                    _buildInferenceHeader(),
                    const SizedBox(height: 10),
                    ..._test.options.map((opt) {
                      final selected = _selectedOption == opt;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: InkWell(
                          onTap: () => _onOptionSelected(opt),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? accentTeal.withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selected
                                    ? accentTeal
                                    : Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              opt,
                              style: TextStyle(
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: selected ? accentTeal : Colors.black87,
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _next,
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

  Widget _buildTestCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _gradientHeader('Test'),
            const SizedBox(height: 6),
            Text(_test.procedure),
            const Divider(height: 24),
            _gradientHeader('Observation'),
            const SizedBox(height: 8),
            Text(
              _test.observation,
              style: const TextStyle(
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
