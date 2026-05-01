import 'package:flutter/material.dart';
import 'package:chemstudio/screens/WET_TEST/D_WET/group0/group0analysis.dart'; // ⚠️ TEMPORARY: Added for database reset


const Color primaryBlue = Color(0xFF004C91);

class WetTestIntroDScreen extends StatelessWidget {
  const WetTestIntroDScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFF),

      // ------------------- APP BAR -------------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryBlue),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          "Salt D : Wet Test",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF075792),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ------------------ FLASK ICON ------------------
            const SizedBox(height: 20),
            const Icon(
              Icons.science_rounded,
              color: Color(0xFF0097A7),
              size: 60,
            ),

            const SizedBox(height: 10),

            // ------------------ TITLE ------------------
            const Text(
              "Welcome to the Wet Test Simulation",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A4A78),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            const Text(
              "Get ready to prepare your Original Solution (O.S.) and analyze cation groups.",
              style: TextStyle(fontSize: 15, color: Colors.black54),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 25),

            // ------------------ STEPPER CONTAINER ------------------
            Container(
              padding: const EdgeInsets.symmetric(vertical: 25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Step 1
                      _stepCircle(isActive: true, number: "1"),
                      _stepDivider(),
                      _stepCircle(isActive: false, number: "2"),
                      _stepDivider(),
                      _stepCircle(isActive: false, number: "3"),
                    ],
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Preparation   →   Group Analysis   →   Confirmatory Tests",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // ------------------ FIRST CARD ------------------
            _infoCard(
              icon: Icons.opacity_rounded,
              title: "(C) PREPARATION OF ORIGINAL SOLUTION (O.S.)",
              content: const Text(
                "Take a small quantity of mixture into a beaker and add two test tubes (20 mL) of water. "
                "Stir with a glass rod to dissolve the mixture. "
                "If the mixture does not dissolve completely, then warm it gently until a clear solution is obtained. "
                "This clear solution is used as the O.S. for further tests.",
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ------------------ SECOND CARD ------------------
            _infoCard(
              icon: Icons.science_outlined,
              title: "(D) DETECTION AND ANALYSIS OF GROUPS",
              content: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text:
                          "Two groups must be detected for two basic radicals.\n"
                          "Follow the sequence from Group 0 to Group VI.\n\n",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: "(1) If Group 0 is present:\n",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: "Detect one group from Group I–VI.\n\n",
                      style: TextStyle(color: Colors.red),
                    ),
                    TextSpan(
                      text: "(2) If Group 0 is absent:\n",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: "(i) "),
                    TextSpan(
                      text: "Detect two groups from Group I–VI.\n",
                      style: TextStyle(color: Colors.red),
                    ),
                    TextSpan(
                      text:
                          "(ii) Add group reagents till first radical is completely precipitated.\n"
                          "(iii) Filter the solution (boil to remove H₂S if Group II or IV present).\n"
                          "(iv) With residue, perform confirmatory test for the first radical.\n"
                          "(v) With filtrate, continue analysis for the second radical.",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ------------------ NEXT BUTTON ------------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WetTestDGroupZeroScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00ACB1),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------ STEP CIRCLE ------------------
  Widget _stepCircle({required bool isActive, required String number}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF00ACB1) : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Text(
        number,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Stepper divider line
  Widget _stepDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 40,
      height: 3,
      color: Colors.grey.shade300,
    );
  }

  // ------------------ INFO CARD ------------------
  Widget _infoCard({
    required IconData icon,
    required String title,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 7, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Color(0xFF00AABD), size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF005B84),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}
