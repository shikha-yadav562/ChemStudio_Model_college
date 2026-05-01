import 'package:chemstudio/screens/WET_TEST/B_WET/group_5/group5_BA_ct.dart';
import 'package:chemstudio/screens/WET_TEST/B_WET/group_5/group5_CA_ct.dart';
import 'package:chemstudio/screens/WET_TEST/B_WET/group_5/group5_SR_ct.dart';
import 'package:flutter/material.dart';

const Color primaryBlue = Color(0xFF004C91);
const Color accentTeal = Color(0xFF00A6A6);

class Analysis_BA_SR_CA extends StatefulWidget {
  const Analysis_BA_SR_CA({super.key});

  @override
  State<Analysis_BA_SR_CA> createState() => _Analysis_BA_SR_CAState();
}

class _Analysis_BA_SR_CAState extends State<Analysis_BA_SR_CA> {
  String? selectedOption;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: _buildContent(),
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: _buildNavigationBar(),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Analysis Group V",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _solutionCard(),
        const SizedBox(height: 12),

        _testCard(),
        const SizedBox(height: 20),

        _gradientTitle("Select the correct inference:"),
        const SizedBox(height: 10),

        _buildOption("Ba²⁺ present"),
        _buildOption("Ca²⁺ present"),
        _buildOption("Sr²⁺ present"),
      ],
    );
  }

  // ==================== NAVIGATION ====================

  Widget _buildNavigationBar() {
    VoidCallback? onNextPressed;

    if (selectedOption != null) {
      if (selectedOption == "Ba²⁺ present") {
        onNextPressed = () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Group5CTBaScreen()),
          );
        };
      } else if (selectedOption == "Ca²⁺ present") {
        onNextPressed = () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Group5CTCaScreen()),
          );
        };
      } else if (selectedOption == "Sr²⁺ present") {
        onNextPressed = () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Group5CTSrScreen()),
          );
        };
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          icon: const Icon(Icons.arrow_back, size: 20),
          label: const Text('Previous', style: TextStyle(fontSize: 16)),
        ),
        ElevatedButton.icon(
          onPressed: onNextPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedOption != null
                ? primaryBlue
                : Colors.grey.shade400,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: const StadiumBorder(),
          ),
          icon: const Icon(Icons.arrow_forward, size: 20),
          label: const Text('Next', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  // ==================== SOLUTION CARD ====================

  Widget _solutionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradientText(
              "Solution",
              gradient: LinearGradient(colors: [accentTeal, primaryBlue]),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              "Dissolve the white ppt in hot acetic acid and use this (acetate) solution for further tests.",
              style: TextStyle(
                fontSize: 15,
                color: primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TEST CARD ====================

  Widget _testCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradientText(
              "Test",
              gradient: LinearGradient(colors: [accentTeal, primaryBlue]),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              "Above solution + K₂CrO₄",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
            ),
            Divider(height: 22),
            GradientText(
              "Observation",
              gradient: LinearGradient(colors: [accentTeal, primaryBlue]),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              "Yellow Ppt",
              style: TextStyle(
                fontSize: 15,
                color: primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== OPTIONS ====================

  Widget _buildOption(String text) {
    final bool selected = selectedOption == text;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => setState(() => selectedOption = text),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? accentTeal.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? accentTeal : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: selected ? accentTeal : Colors.black,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== GRADIENT TITLE ====================

  Widget _gradientTitle(String text) {
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

// ==================== GRADIENT TEXT WIDGET ====================

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText(
    this.text, {
    required this.style,
    required this.gradient,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}
