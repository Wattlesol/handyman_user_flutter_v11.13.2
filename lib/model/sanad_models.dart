class SanadFoundationResponse {
  final Map<String, dynamic> terminology;
  final Map<String, dynamic> roles;
  final List<String> requestLifecycle;
  final List<String> documentVisibility;
  final bool aiEnabled;

  SanadFoundationResponse({
    required this.terminology,
    required this.roles,
    required this.requestLifecycle,
    required this.documentVisibility,
    required this.aiEnabled,
  });

  factory SanadFoundationResponse.fromJson(Map<String, dynamic> json) {
    return SanadFoundationResponse(
      terminology: Map<String, dynamic>.from(json['terminology'] ?? {}),
      roles: Map<String, dynamic>.from(json['roles'] ?? {}),
      requestLifecycle: List<String>.from(json['request_lifecycle'] ?? []),
      documentVisibility: List<String>.from(json['document_visibility'] ?? []),
      aiEnabled: json['ai'] is Map ? json['ai']['enabled'] == true : false,
    );
  }
}

class SanadAiInteraction {
  final int? id;
  final String question;
  final String answer;
  final double? confidence;
  final bool requiresEscalation;
  final String status;

  SanadAiInteraction({
    this.id,
    required this.question,
    required this.answer,
    this.confidence,
    required this.requiresEscalation,
    required this.status,
  });

  factory SanadAiInteraction.fromJson(Map<String, dynamic> json) {
    return SanadAiInteraction(
      id: json['id'],
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      confidence: json['confidence'] == null
          ? null
          : double.tryParse(json['confidence'].toString()),
      requiresEscalation: json['requires_escalation'] == true,
      status: json['status'] ?? '',
    );
  }
}
