// wet_test_answers.dart
import 'package:chemstudio/models/group_status.dart';

class ConfirmatoryTest {
  final String ion;
  final String observation;
  final String correctOption;

  const ConfirmatoryTest({
    required this.ion,
    required this.observation,
    required this.correctOption,
  });
}

// -------------------- Group Detection --------------------
const Map<int, GroupStatus> wetTestGroups = {
  0: GroupStatus.present,
  1: GroupStatus.absent,
  2: GroupStatus.absent,
  3: GroupStatus.present,
  4: GroupStatus.absent,
  5: GroupStatus.absent,
  6: GroupStatus.absent,
};

// -------------------- Confirmatory Test Answers --------------------
const Map<String, ConfirmatoryTest> wetTestCTAnswers = {
  "NH4+": ConfirmatoryTest(
    ion: "NH4+",
    observation: "Brown ppt/colouration of basic mercury (II) amidoiodine",
    correctOption: "NH₄⁺ Confirmed",
  ),

  "Pb2+": ConfirmatoryTest(
    ion: "Pb2+",
    observation: "Yellow Precipitate",
    correctOption: "Pb²⁺ Confirmed",
  ),

  "Cu2+": ConfirmatoryTest(
    ion: "Cu2+",
    observation: "White ppt in brown coloured solution",
    correctOption: "Cu²⁺ confirmed",
  ),

  "As3+": ConfirmatoryTest(
    ion: "As3+",
    observation: "Yellow ppt",
    correctOption: "As³⁺ confirmed",
  ),

  "Fe3+": ConfirmatoryTest(
    ion: "Fe3+",
    observation: "Prussian blue ppt or colour",
    correctOption: "Fe³⁺ confirmed",
  ),

  "Al3+": ConfirmatoryTest(
    ion: "Al3+",
    observation: "White gelatinous ppt (Soluble in excess NaOH)",
    correctOption: "Al³⁺ confirmed",
  ),
  "Ni2+": ConfirmatoryTest(
    ion: "Ni2+",
    observation: "Light green ppt",
    correctOption: "Ni²⁺ confirmed",
  ),
  "Co2+": ConfirmatoryTest(
    ion: "Co2+",
    observation: "Blue colour",
    correctOption: "Co²⁺ confirmed",
  ),
  "Mn2+": ConfirmatoryTest(
    ion: "Mn2+",
    observation: "Pink / violet colour",
    correctOption: "Mn²⁺ confirmed",
  ),
  "Zn2+": ConfirmatoryTest(
    ion: "Zn2+",
    observation: "White ppt soluble in excess NaOH",
    correctOption: "Zn²⁺ confirmed",
  ),
  "Ba2+": ConfirmatoryTest(
    ion: "Ba2+",
    observation: "Yellow ppt",
    correctOption: "Ba²⁺ confirmed",
  ),
  "Ca2+": ConfirmatoryTest(
    ion: "Ca2+",
    observation: "White ppt",
    correctOption: "Ca²⁺ confirmed",
  ),
  "Sr2+": ConfirmatoryTest(
    ion: "Sr2+",
    observation: "White ppt",
    correctOption: "Sr²⁺ confirmed",
  ),
  "Mg2+": ConfirmatoryTest(
    ion: "Mg2+",
    observation: "No rose red ppt with titan yellow",
    correctOption: "Mg²⁺ confirmed",
  ),
};
