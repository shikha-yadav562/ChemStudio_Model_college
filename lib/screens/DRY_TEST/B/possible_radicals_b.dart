import 'package:flutter/material.dart';
import 'package:chemstudio/screens/DRY_TEST/B/dry_test_b.dart';
import '../../welcome_screen.dart'; // Ensure correct path for WelcomeScreen

const Color primaryBlue = Color(0xFF004C91);
const Color accentTeal = Color(0xFF00A6A6);

class PossibleRadicalsBScreen extends StatefulWidget {
  final Map<int, String> userAnswers;
  final List<TestItem> tests;
  final Map<int, String> preliminaryAnswers;

  const PossibleRadicalsBScreen({
    super.key,
    required this.userAnswers,
    required this.tests,
    required this.preliminaryAnswers,
  });

  @override
  State<PossibleRadicalsBScreen> createState() =>
      _PossibleRadicalsBScreenState();
}

class _PossibleRadicalsBScreenState extends State<PossibleRadicalsBScreen> {
  final List<String> _radicals = [
    'Cu²⁺',
    'NH₄⁺',
    'Pb²⁺',
    'Fe³⁺',
    'Ba²⁺',
    'Ni²⁺',
  ];

  final Set<String> _selectedRadicals = {};

  void _toggleRadical(String radical) {
    setState(() {
      if (_selectedRadicals.contains(radical)) {
        _selectedRadicals.remove(radical);
      } else {
        if (_selectedRadicals.length < 3) {
          _selectedRadicals.add(radical);
        } else {
          // 2. Notification displayed at the TOP of the screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('You can select a maximum of 3 radicals.'),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 100,
                left: 10,
                right: 10,
              ),
            ),
          );
        }
      }
    });
  }

  bool _isSelectionValid() {
    return _selectedRadicals.length >= 2 && _selectedRadicals.length <= 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        // 1a. Top-left back arrow navigates to Welcome Screen
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryBlue),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              (route) => false,
            );
          },
        ),
        title: const Text(
          'Salt B',
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'On the basis of the dry test, possible radicals can be:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _radicals.length,
                itemBuilder: (context, index) {
                  final radical = _radicals[index];
                  final isSelected = _selectedRadicals.contains(radical);

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accentTeal.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? accentTeal : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: CheckboxListTile(
                      title: Text(
                        radical,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? accentTeal : Colors.black87,
                        ),
                      ),
                      value: isSelected,
                      activeColor: accentTeal,
                      checkColor: Colors.white,
                      onChanged: (_) => _toggleRadical(radical),
                      controlAffinity: ListTileControlAffinity.trailing,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1b. Previous button returns to Flame Test (DryTestCScreen)
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DryTestBScreen(
                          preliminaryAnswers: widget.preliminaryAnswers,
                          startIndex:
                              2, // This tells the screen to open at the Flame Test
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: TextButton.styleFrom(foregroundColor: primaryBlue),
                ),
                ElevatedButton.icon(
                  onPressed: _isSelectionValid()
                      ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SaltBResultScreen(
                                userAnswers: widget.userAnswers,
                                tests: widget.tests,
                                preliminaryAnswers: widget.preliminaryAnswers,
                              ),
                            ),
                          );
                        }
                      : null,
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
    );
  }
}
