import 'package:flutter/material.dart';
import 'package:chemstudio/DB/database_helper.dart';
import 'package:chemstudio/models/group_status.dart';
import 'package:chemstudio/screens/WET_TEST/D_WET/D_wet_test_answers.dart';

const Color primaryBlue = Color(0xFF004C91);
const Color accentTeal = Color(0xFF00A6A6);

class WetTestDFinalResultScreen extends StatefulWidget {
  final String salt;
  const WetTestDFinalResultScreen({super.key, required this.salt});

  @override
  State<WetTestDFinalResultScreen> createState() =>
      _WetTestDFinalResultScreenState();
}

class _WetTestDFinalResultScreenState extends State<WetTestDFinalResultScreen> {
  bool isLoading = true;
  bool _showRecheck = false;

  Map<int, GroupStatus> studentGroups = {};
  List<String> selectedIons = [];
  Map<int, String?> _studentCTAnswers = {};

  final Map<int, String> correctIonsPerGroup = {
    0: 'NH4+',
    1: 'Pb2+',
    2: 'Cu2+',
    3: 'Al3+',
    4: 'Ni2+',
    5: 'Ca2+',
    6: 'Mg2+',
  };

  final List<Map<String, dynamic>> ctTests = [
    {'ion': 'NH4+', 'group': 0, 'questionId': 2},
    {'ion': 'Pb2+', 'group': 1, 'questionId': 5},
    {'ion': 'Cu2+', 'group': 2, 'questionId': 8},
    {'ion': 'As3+', 'group': 2, 'questionId': 9},
    {'ion': 'Fe3+', 'group': 3, 'questionId': 12},
    {'ion': 'Al3+', 'group': 3, 'questionId': 13},
    {'ion': 'Ni2+', 'group': 4, 'questionId': 16},
    {'ion': 'Co2+', 'group': 4, 'questionId': 17},
    {'ion': 'Mn2+', 'group': 4, 'questionId': 18},
    {'ion': 'Zn2+', 'group': 4, 'questionId': 19},
    {'ion': 'Ba2+', 'group': 5, 'questionId': 22},
    {'ion': 'Ca2+', 'group': 5, 'questionId': 23},
    {'ion': 'Sr2+', 'group': 5, 'questionId': 24},
    {'ion': 'Mg2+', 'group': 6, 'questionId': 27},
  ];

  // ── Correct answers for Salt D ──────────────────────────────────
  static const Map<int, GroupStatus> _correctGroups = {
    0: GroupStatus.present,
    1: GroupStatus.absent,
    2: GroupStatus.absent,
    3: GroupStatus.absent,
    4: GroupStatus.present,
    5: GroupStatus.absent,
    6: GroupStatus.absent,
  };

  static const Map<int, String> _correctCT = {
    0: 'NH₄⁺ Confirmed',
    4: 'Ni²⁺ confirmed',
  };

  static const Map<int, List<int>> _groupCTIds = {
    0: [2],
    1: [5],
    2: [8, 9],
    3: [12, 13],
    4: [16, 17, 18, 19],
    5: [22, 23, 24],
    6: [27],
  };

  static const Map<int, String> _groupNames = {
    0: 'Group 0 (NH₄⁺)',
    1: 'Group I (Pb²⁺)',
    2: 'Group II (Cu²⁺/As³⁺)',
    3: 'Group III (Fe³⁺/Al³⁺)',
    4: 'Group IV (Ni²⁺/Co²⁺/Mn²⁺/Zn²⁺)',
    5: 'Group V (Ba²⁺/Ca²⁺/Sr²⁺)',
    6: 'Group VI (Mg²⁺)',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper.instance;

    studentGroups = await db.getStudentGroupDecisions(widget.salt);
    await _identifySelectedIons();

    // Load all CT answers for recheck
    final Map<int, String?> ctAnswers = {};
    for (final ids in _groupCTIds.values) {
      for (final id in ids) {
        ctAnswers[id] = await db.getStudentAnswer('SaltD_WetTest', id);
      }
    }
    _studentCTAnswers = ctAnswers;

    setState(() => isLoading = false);
  }

  Future<void> _identifySelectedIons() async {
    final List<String> ions = [];
    for (final ct in ctTests) {
      final questionId = ct['questionId'] as int;
      final ion = ct['ion'] as String;
      final studentAnswer = await DatabaseHelper.instance.getStudentAnswer(
        'SaltD_WetTest',
        questionId,
      );
      if (studentAnswer != null && studentAnswer.trim().isNotEmpty) {
        ions.add(ion);
      }
    }
    selectedIons = ions.take(2).toList();
  }

  bool isCorrectIonForGroup(String ion, int group) =>
      correctIonsPerGroup[group] == ion;

  Future<bool> isCTCorrect({
    required int group,
    required String ion,
    required int questionId,
  }) async {
    if (wetTestGroups[group] != GroupStatus.present) return false;
    if (!isCorrectIonForGroup(ion, group)) return false;
    final studentAnswer = await DatabaseHelper.instance.getStudentAnswer(
      'SaltD_WetTest',
      questionId,
    );
    final correct = wetTestCTAnswers[ion]?.correctOption;
    if (studentAnswer == null || correct == null) return false;
    return studentAnswer.trim().toLowerCase() == correct.trim().toLowerCase();
  }

  String formatIon(String ion) => ion
      .replaceAll('2+', '²⁺')
      .replaceAll('3+', '³⁺')
      .replaceAll('4+', '⁴⁺');

  // ── Recheck helper ─────────────────────────────────────────────
  String? _studentCTForGroup(int group) {
    for (final id in _groupCTIds[group] ?? []) {
      final ans = _studentCTAnswers[id];
      if (ans != null && ans.trim().isNotEmpty) return ans;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFE8F5F3),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00897B)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F5F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00897B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Results',
          style: TextStyle(color: Color(0xFF00897B), fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.check_circle, size: 100, color: Color(0xFF00897B)),
            const SizedBox(height: 24),
            const Text(
              'The given inorganic mixture contains the\nfollowing cations:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 32),

            // ── Ion result cards ───────────────────────────
            ...selectedIons.map((ion) {
              final ct = ctTests.firstWhere((e) => e['ion'] == ion);
              return FutureBuilder<bool>(
                future: isCTCorrect(
                  group: ct['group'],
                  ion: ion,
                  questionId: ct['questionId'],
                ),
                builder: (context, snapshot) {
                  final isCorrect = snapshot.data ?? false;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 24),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCorrect ? Colors.green : Colors.red,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          formatIon(ion),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isCorrect
                                ? Colors.green[800]
                                : Colors.red[800],
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect ? Colors.green : Colors.red,
                          size: 32,
                        ),
                      ],
                    ),
                  );
                },
              );
            }),

            const SizedBox(height: 16),

            // ── RECHECK BUTTON ─────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(
                  _showRecheck
                      ? Icons.keyboard_arrow_up
                      : Icons.fact_check_outlined,
                ),
                label: Text(
                  _showRecheck ? 'Hide Recheck' : 'Recheck All Groups',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () =>
                    setState(() => _showRecheck = !_showRecheck),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // ── RECHECK PANEL ──────────────────────────────
            if (_showRecheck) ...[
              const SizedBox(height: 20),
              ...List.generate(7, (i) => _buildGroupReviewCard(i)),
            ],

            const SizedBox(height: 16),

            // ── BACK BUTTON ────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF00897B)),
                label: const Text(
                  'BACK',
                  style: TextStyle(
                    color: Color(0xFF00897B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF00897B), width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Group review card ──────────────────────────────────────────
  Widget _buildGroupReviewCard(int group) {
    final correctStatus = _correctGroups[group]!;
    final studentStatus = studentGroups[group];
    final groupCorrect = studentStatus == correctStatus;

    final studentCT = _studentCTForGroup(group);
    final correctCT = _correctCT[group];

    final ctCorrect = correctStatus == GroupStatus.present &&
        studentCT != null &&
        correctCT != null &&
        studentCT.trim().toLowerCase() == correctCT.trim().toLowerCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [accentTeal, primaryBlue]),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Text(
                  _groupNames[group]!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Icon(
                  groupCorrect ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),

          // Group status side-by-side
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: _statusBox(
                    label: 'Your Answer',
                    status: studentStatus,
                    isCorrect: groupCorrect,
                    isStudentBox: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _statusBox(
                    label: 'Correct Answer',
                    status: correctStatus,
                    isCorrect: true,
                    isStudentBox: false,
                  ),
                ),
              ],
            ),
          ),

          // CT section
          if (studentCT != null || correctStatus == GroupStatus.present)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  const Text(
                    'Confirmatory Test',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _ctBox(
                          label: 'Your CT',
                          value: studentCT ?? '— Not attempted',
                          isCorrect: studentCT != null && ctCorrect,
                          isWrong: studentCT != null && !ctCorrect,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ctBox(
                          label: 'Correct CT',
                          value: correctCT ?? '— Group absent',
                          isCorrect: correctCT != null,
                          isWrong: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusBox({
    required String label,
    required GroupStatus? status,
    required bool isCorrect,
    required bool isStudentBox,
  }) {
    final isPresent = status == GroupStatus.present;
    final notAttempted = status == null;

    Color bg, border, text;
    IconData icon;

    if (notAttempted) {
      bg = Colors.grey.shade100;
      border = Colors.grey.shade300;
      text = Colors.grey;
      icon = Icons.help_outline;
    } else if (!isStudentBox) {
      bg = const Color(0xFFE0F7FA);
      border = accentTeal;
      text = primaryBlue;
      icon = isPresent
          ? Icons.check_circle_outline
          : Icons.remove_circle_outline;
    } else if (isCorrect) {
      bg = const Color(0xFFE8F5E9);
      border = Colors.green;
      text = Colors.green.shade800;
      icon = Icons.check_circle;
    } else {
      bg = const Color(0xFFFFEBEE);
      border = Colors.red;
      text = Colors.red.shade800;
      icon = Icons.cancel;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: text.withOpacity(0.7),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, color: text, size: 16),
              const SizedBox(width: 4),
              Text(
                notAttempted
                    ? 'Not reached'
                    : (isPresent ? 'Present' : 'Absent'),
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: text),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ctBox({
    required String label,
    required String value,
    required bool isCorrect,
    required bool isWrong,
  }) {
    Color bg, border, text;

    if (isWrong) {
      bg = const Color(0xFFFFEBEE);
      border = Colors.red;
      text = Colors.red.shade800;
    } else if (isCorrect &&
        value != '— Group absent' &&
        value != '— Not attempted') {
      bg = const Color(0xFFE8F5E9);
      border = Colors.green;
      text = Colors.green.shade800;
    } else {
      bg = const Color(0xFFE0F7FA);
      border = accentTeal;
      text = primaryBlue;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: text.withOpacity(0.7),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: text)),
        ],
      ),
    );
  }
}