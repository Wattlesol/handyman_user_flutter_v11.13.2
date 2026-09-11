import "package:booking_system_flutter/model/service_data_model.dart";

class SanadRequestDetailModel {
  int? id;
  String? sanadReference;
  String? quickReference;
  int? serviceId;
  String? serviceName;
  String? serviceDescription;
  num? servicePrice;
  String? serviceProvider;
  String? supportTeam;
  String? status;
  String? sanadStage;
  String? stageLabel;
  String? stageDescription;
  String? sanadPriority;
  num? progress;
  String? slaDueAt;
  String? expectedCompletionAt;
  String? createdAt;
  String? address;
  bool? cancellationAllowed;
  String? cancellationNotice;
  List<SanadBuzzAlertItem>? openBuzzAlerts;
  List<SanadRequestTimelineItem>? timeline;
  List<SanadRequiredDocumentItem>? requiredDocuments;
  List<SanadDocumentChoiceItem>? documentChoices;
  List<SanadPendingDocumentRequestItem>? pendingDocumentRequests;
  List<SanadVerifiedDocumentItem>? verifiedDocuments;
  SanadBillingInfo? billing;

  SanadRequestDetailModel({
    this.id,
    this.sanadReference,
    this.quickReference,
    this.serviceId,
    this.serviceName,
    this.serviceDescription,
    this.servicePrice,
    this.serviceProvider,
    this.supportTeam,
    this.status,
    this.sanadStage,
    this.stageLabel,
    this.stageDescription,
    this.sanadPriority,
    this.progress,
    this.slaDueAt,
    this.expectedCompletionAt,
    this.createdAt,
    this.address,
    this.cancellationAllowed,
    this.cancellationNotice,
    this.openBuzzAlerts,
    this.timeline,
    this.requiredDocuments,
    this.documentChoices,
    this.pendingDocumentRequests,
    this.verifiedDocuments,
    this.billing,
  });

  factory SanadRequestDetailModel.fromJson(Map<String, dynamic> json) {
    return SanadRequestDetailModel(
      id: json["id"],
      sanadReference: json["sanad_reference"],
      quickReference: json["quick_reference"],
      serviceId: json["service_id"],
      serviceName: json["service_name"],
      serviceDescription: json["service_description"],
      servicePrice: json["service_price"],
      serviceProvider: json["service_provider"] ?? "Quick",
      supportTeam: json["support_team"] ?? "Quick team",
      status: json["status"],
      sanadStage: json["sanad_stage"],
      stageLabel: json["stage_label"],
      stageDescription: json["stage_description"],
      sanadPriority: json["sanad_priority"],
      progress: json["progress"],
      slaDueAt: json["sla_due_at"],
      expectedCompletionAt: json["expected_completion_at"],
      createdAt: json["created_at"],
      address: json["address"],
      cancellationAllowed: json["cancellation_allowed"] ?? false,
      cancellationNotice: json["cancellation_notice"],
      openBuzzAlerts: json["open_buzz_alerts"] != null
          ? (json["open_buzz_alerts"] as List)
              .map((i) => SanadBuzzAlertItem.fromJson(i))
              .toList()
          : [],
      timeline: json["timeline"] != null
          ? (json["timeline"] as List)
              .map((i) => SanadRequestTimelineItem.fromJson(i))
              .toList()
          : [],
      requiredDocuments: json["required_documents"] != null
          ? (json["required_documents"] as List)
              .map((i) => SanadRequiredDocumentItem.fromJson(i))
              .toList()
          : [],
      documentChoices: json["document_choices"] != null
          ? (json["document_choices"] as List)
              .map((i) => SanadDocumentChoiceItem.fromJson(i))
              .toList()
          : [],
      pendingDocumentRequests: json["pending_document_requests"] != null
          ? (json["pending_document_requests"] as List)
              .map((i) => SanadPendingDocumentRequestItem.fromJson(i))
              .toList()
          : [],
      verifiedDocuments: json["verified_documents"] != null
          ? (json["verified_documents"] as List)
              .map((i) => SanadVerifiedDocumentItem.fromJson(i))
              .toList()
          : [],
      billing: json["billing"] != null
          ? SanadBillingInfo.fromJson(json["billing"])
          : null,
    );
  }
}

class SanadBuzzAlertItem {
  int? id;
  String? message;
  String? severity;
  String? createdAt;

  SanadBuzzAlertItem({this.id, this.message, this.severity, this.createdAt});

  factory SanadBuzzAlertItem.fromJson(Map<String, dynamic> json) {
    return SanadBuzzAlertItem(
      id: json["id"],
      message: json["message"],
      severity: json["severity"],
      createdAt: json["created_at"],
    );
  }
}

class SanadRequestTimelineItem {
  int? id;
  String? action;
  String? title;
  String? note;
  String? actor;
  String? createdAt;

  SanadRequestTimelineItem({
    this.id,
    this.action,
    this.title,
    this.note,
    this.actor,
    this.createdAt,
  });

  factory SanadRequestTimelineItem.fromJson(Map<String, dynamic> json) {
    return SanadRequestTimelineItem(
      id: json["id"],
      action: json["action"],
      title: json["title"],
      note: json["note"],
      actor: json["actor"],
      createdAt: json["created_at"],
    );
  }
}

class SanadRequiredDocumentItem {
  String? key;
  String? name;
  String? status;
  bool? required;
  List<dynamic>? mimeTypes;

  SanadRequiredDocumentItem({
    this.key,
    this.name,
    this.status,
    this.required,
    this.mimeTypes,
  });

  factory SanadRequiredDocumentItem.fromJson(Map<String, dynamic> json) {
    return SanadRequiredDocumentItem(
      key: json["key"],
      name: json["name"],
      status: json["status"],
      required: json["required"] ?? true,
      mimeTypes: json["mime_types"] ?? [],
    );
  }
}

class SanadDocumentChoiceItem {
  String? id;
  String? key;
  String? name;
  String? label;
  bool? required;
  int? documentRequestId;

  SanadDocumentChoiceItem({
    this.id,
    this.key,
    this.name,
    this.label,
    this.required,
    this.documentRequestId,
  });

  factory SanadDocumentChoiceItem.fromJson(Map<String, dynamic> json) {
    return SanadDocumentChoiceItem(
      id: json["id"],
      key: json["key"],
      name: json["name"],
      label: json["label"],
      required: json["required"] ?? false,
      documentRequestId: json["document_request_id"],
    );
  }
}

class SanadPendingDocumentRequestItem {
  int? id;
  String? documentName;
  String? reason;
  String? instructions;
  String? status;
  String? dueAt;

  SanadPendingDocumentRequestItem({
    this.id,
    this.documentName,
    this.reason,
    this.instructions,
    this.status,
    this.dueAt,
  });

  factory SanadPendingDocumentRequestItem.fromJson(Map<String, dynamic> json) {
    return SanadPendingDocumentRequestItem(
      id: json["id"],
      documentName: json["document_name"],
      reason: json["reason"],
      instructions: json["instructions"],
      status: json["status"],
      dueAt: json["due_at"],
    );
  }
}

class SanadVerifiedDocumentItem {
  int? id;
  String? documentType;
  String? documentKey;
  String? fileName;
  String? fileUrl;
  String? approvedAt;
  String? status;

  SanadVerifiedDocumentItem({
    this.id,
    this.documentType,
    this.documentKey,
    this.fileName,
    this.fileUrl,
    this.approvedAt,
    this.status,
  });

  factory SanadVerifiedDocumentItem.fromJson(Map<String, dynamic> json) {
    return SanadVerifiedDocumentItem(
      id: json["id"],
      documentType: json["document_type"],
      documentKey: json["document_key"],
      fileName: json["file_name"],
      fileUrl: json["file_url"],
      approvedAt: json["approved_at"],
      status: json["status"],
    );
  }
}

class SanadBillingInfo {
  bool? invoiceAvailable;
  String? invoiceUrl;
  num? serviceFee;
  num? vat;
  num? totalAmount;
  String? paymentStatus;
  String? paymentMethod;

  SanadBillingInfo({
    this.invoiceAvailable,
    this.invoiceUrl,
    this.serviceFee,
    this.vat,
    this.totalAmount,
    this.paymentStatus,
    this.paymentMethod,
  });

  factory SanadBillingInfo.fromJson(Map<String, dynamic> json) {
    return SanadBillingInfo(
      invoiceAvailable: json["invoice_available"] ?? false,
      invoiceUrl: json["invoice_url"],
      serviceFee: json["service_fee"] ?? 0,
      vat: json["vat"] ?? 0,
      totalAmount: json["total_amount"] ?? 0,
      paymentStatus: json["payment_status"] ?? "pending",
      paymentMethod: json["payment_method"] ?? "Not Specified",
    );
  }
}
