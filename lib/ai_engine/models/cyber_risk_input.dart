/// Cyber risk input model.
library;

class CyberRiskInput {
  final String inputType; // url, qr, apk, screenshot, permission, device
  final String inputData;
  final Map<String, dynamic>? metadata;

  const CyberRiskInput({
    required this.inputType,
    required this.inputData,
    this.metadata,
  });
}
