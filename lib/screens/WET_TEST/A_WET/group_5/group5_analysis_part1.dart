import 'package:flutter/material.dart';
import 'group5analysis_BA_SR_CA.dart';

const Color primaryBlue = Color(0xFF004C91);
const Color accentTeal = Color(0xFF00A6A6);

class saltAGroup5AnalysisPart1 extends StatefulWidget {
  const saltAGroup5AnalysisPart1({super.key});

  @override
  State<saltAGroup5AnalysisPart1> createState() => _saltAGroup5AnalysisPart1State();
}

class _saltAGroup5AnalysisPart1State extends State<saltAGroup5AnalysisPart1>
    with SingleTickerProviderStateMixin {
  String? selectedOption;
  late final AnimationController _animController;
  late final Animation<double> _fadeSlide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeSlide = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  void _next() {
    if (selectedOption != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const saltAAnalysis_BA_SR_CA()),
      );
    }
  }

  // Bottom "Previous" button still pops back to the detection screen
  void _prev() {
    Navigator.pop(context);
  }

  Widget _gradientHeader(String text) {
    return ShaderMask(
      shaderCallback: (bounds) =>
          const LinearGradient(colors: [accentTeal, primaryBlue]).createShader(bounds),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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
            _gradientHeader("Test"),
            
            const SizedBox(height: 6),
            const Text(
              "O.S / Filtrate + NH₄Cl + NH₄OH (till alkaline) + (NH₄)₂CO₃",
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
            const Divider(height: 22),
            _gradientHeader("Observation"),
            const SizedBox(height: 6),
            const Text(
              "White ppt",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primaryBlue),
            ),
          ],
        ),
      ),
    );
  }

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
            color: selected ? accentTeal.withOpacity(0.12) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? accentTeal : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? accentTeal : Colors.black,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
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
          shaderCallback: (bounds) =>
              const LinearGradient(colors: [accentTeal, primaryBlue]).createShader(bounds),
          child: Text(
            'Salt A: Wet Test',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
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
              const Text(
                "Analysis Group V",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBlue),
              ),
              const SizedBox(height: 12),
              _buildTestCard(),
              const SizedBox(height: 16),
              _gradientHeader("Select the correct inference:"),
              const SizedBox(height: 10),
              _buildOption("Ca²⁺, Ba²⁺, Sr²⁺ maybe present"),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _prev,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  ),
                  ElevatedButton.icon(
                    onPressed: selectedOption != null ? _next : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedOption != null ? primaryBlue : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}