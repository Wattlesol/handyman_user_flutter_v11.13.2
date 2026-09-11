import 'package:nb_utils/nb_utils.dart';

class SanadConversationItem {
  int? id;
  String? sanadReference;
  int? customerId;
  int? serviceId;
  String? serviceName;
  String? serviceNameAr;
  String? serviceNameEn;
  String? serviceImage;
  String? status;
  String? sanadStage;
  String? sanadPriority;
  String? lastMessage;
  String? lastMessageAt;
  String? lastSenderRole;
  int? unreadCount;
  int? buzzCount;
  int? documentPendingCount;
  bool? aiEnabled;
  int? threadId;

  SanadConversationItem({
    this.id,
    this.sanadReference,
    this.customerId,
    this.serviceId,
    this.serviceName,
    this.serviceNameAr,
    this.serviceNameEn,
    this.serviceImage,
    this.status,
    this.sanadStage,
    this.sanadPriority,
    this.lastMessage,
    this.lastMessageAt,
    this.lastSenderRole,
    this.unreadCount = 0,
    this.buzzCount = 0,
    this.documentPendingCount = 0,
    this.aiEnabled = false,
    this.threadId,
  });

  factory SanadConversationItem.fromJson(Map<String, dynamic> json) {
    var service = json['service'] is Map ? json['service'] : null;
    var threads = json['sanad_chat_threads'] is List ? json['sanad_chat_threads'] as List : [];
    var latestThread = threads.isNotEmpty && threads.first is Map ? threads.first : null;
    var messages = latestThread != null && latestThread['messages'] is List ? latestThread['messages'] as List : [];
    var latestMsg = messages.isNotEmpty && messages.first is Map ? messages.first : null;

    var buzzList = json['sanad_buzz_alerts'] is List ? json['sanad_buzz_alerts'] as List : [];
    var docRequests = json['sanad_document_requests'] is List ? json['sanad_document_requests'] as List : [];

    int unread = 0;
    for (var m in messages) {
      if (m is Map && m['read_at'] == null && m['sender_role'] != 'customer' && m['sender_role'] != 'user') {
        unread++;
      }
    }

    int pendingDocs = 0;
    for (var d in docRequests) {
      if (d is Map && (d['status'] == 'pending' || d['status'] == 'replacement_requested')) {
        pendingDocs++;
      }
    }

    return SanadConversationItem(
      id: json['id'],
      sanadReference: json['sanad_reference'] ?? (json['id'] != null ? 'QUICK-${json['id'].toString().padLeft(6, '0')}' : ''),
      customerId: json['customer_id'],
      serviceId: json['service_id'],
      serviceName: service != null ? (service['name'] ?? service['name_en']) : (json['service_name'] ?? 'General Inquiry'),
      serviceNameAr: service != null ? service['name_ar'] : null,
      serviceNameEn: service != null ? service['name_en'] : null,
      serviceImage: service != null ? (service['category_image'] ?? service['image'] ?? '') : '',
      status: json['status'] ?? 'pending',
      sanadStage: json['sanad_stage'] ?? json['status'] ?? 'submitted',
      sanadPriority: json['sanad_priority'] ?? 'normal',
      lastMessage: latestMsg != null ? latestMsg['message'] : (json['description'] ?? 'No messages yet'),
      lastMessageAt: latestMsg != null ? latestMsg['created_at'] : (json['updated_at'] ?? json['created_at']),
      lastSenderRole: latestMsg != null ? latestMsg['sender_role'] : null,
      unreadCount: unread,
      buzzCount: buzzList.length,
      documentPendingCount: pendingDocs,
      aiEnabled: json['ai_first_responder_enabled'] == 1 || json['ai_first_responder_enabled'] == true,
      threadId: latestThread != null ? latestThread['id'] : null,
    );
  }
}

class SanadCommunicationResponse {
  List<SanadChatThreadModel> threads;
  List<SanadDocumentRequestModel> documentRequests;

  SanadCommunicationResponse({
    this.threads = const [],
    this.documentRequests = const [],
  });

  factory SanadCommunicationResponse.fromJson(Map<String, dynamic> json) {
    return SanadCommunicationResponse(
      threads: json['threads'] is List
          ? (json['threads'] as List).map((i) => SanadChatThreadModel.fromJson(i)).toList()
          : [],
      documentRequests: json['document_requests'] is List
          ? (json['document_requests'] as List).map((i) => SanadDocumentRequestModel.fromJson(i)).toList()
          : [],
    );
  }
}

class SanadChatThreadModel {
  int? id;
  int? bookingId;
  String? threadType;
  List<String>? participantRoles;
  int? createdBy;
  String? status;
  String? createdAt;
  String? lastMessageAt;
  List<SanadChatMessageModel> messages;

  SanadChatThreadModel({
    this.id,
    this.bookingId,
    this.threadType,
    this.participantRoles,
    this.createdBy,
    this.status,
    this.createdAt,
    this.lastMessageAt,
    this.messages = const [],
  });

  factory SanadChatThreadModel.fromJson(Map<String, dynamic> json) {
    return SanadChatThreadModel(
      id: json['id'],
      bookingId: json['booking_id'],
      threadType: json['thread_type'],
      participantRoles: json['participant_roles'] is List
          ? (json['participant_roles'] as List).map((e) => e.toString()).toList()
          : [],
      createdBy: json['created_by'],
      status: json['status'],
      createdAt: json['created_at'],
      lastMessageAt: json['last_message_at'],
      messages: json['messages'] is List
          ? (json['messages'] as List).map((i) => SanadChatMessageModel.fromJson(i)).toList()
          : [],
    );
  }
}

class SanadChatMessageModel {
  int? id;
  int? threadId;
  int? senderId;
  String? senderRole;
  String? senderName;
  String? senderAvatar;
  String? message;
  String? messageType;
  int? buzzAlertId;
  int? documentRequestId;
  int? aiInteractionId;
  String? readAt;
  String? createdAt;
  SanadBuzzAlertModel? buzzAlert;
  SanadDocumentRequestModel? documentRequest;
  SanadAiInteractionModel? aiInteraction;

  SanadChatMessageModel({
    this.id,
    this.threadId,
    this.senderId,
    this.senderRole,
    this.senderName,
    this.senderAvatar,
    this.message,
    this.messageType = 'text',
    this.buzzAlertId,
    this.documentRequestId,
    this.aiInteractionId,
    this.readAt,
    this.createdAt,
    this.buzzAlert,
    this.documentRequest,
    this.aiInteraction,
  });

  factory SanadChatMessageModel.fromJson(Map<String, dynamic> json) {
    var sender = json['sender'] is Map ? json['sender'] : null;
    return SanadChatMessageModel(
      id: json['id'],
      threadId: json['thread_id'],
      senderId: json['sender_id'],
      senderRole: json['sender_role'] ?? 'user',
      senderName: sender != null ? (sender['display_name'] ?? sender['first_name']) : null,
      senderAvatar: sender != null ? sender['profile_image'] : null,
      message: json['message'] ?? '',
      messageType: json['message_type'] ?? 'text',
      buzzAlertId: json['buzz_alert_id'],
      documentRequestId: json['document_request_id'],
      aiInteractionId: json['ai_interaction_id'],
      readAt: json['read_at'],
      createdAt: json['created_at'],
      buzzAlert: json['buzz_alert'] is Map ? SanadBuzzAlertModel.fromJson(json['buzz_alert']) : null,
      documentRequest: json['document_request'] is Map ? SanadDocumentRequestModel.fromJson(json['document_request']) : null,
      aiInteraction: json['ai_interaction'] is Map ? SanadAiInteractionModel.fromJson(json['ai_interaction']) : null,
    );
  }

  bool get isMe {
    return senderRole == 'customer' || senderRole == 'user';
  }

  bool get isAi {
    return senderRole == 'ai' || aiInteractionId != null;
  }
}

class SanadBuzzAlertModel {
  int? id;
  int? bookingId;
  int? userId;
  String? message;
  String? priority;
  String? status;
  String? acknowledgedAt;
  String? createdAt;

  SanadBuzzAlertModel({
    this.id,
    this.bookingId,
    this.userId,
    this.message,
    this.priority,
    this.status,
    this.acknowledgedAt,
    this.createdAt,
  });

  factory SanadBuzzAlertModel.fromJson(Map<String, dynamic> json) {
    return SanadBuzzAlertModel(
      id: json['id'],
      bookingId: json['booking_id'],
      userId: json['user_id'],
      message: json['message'],
      priority: json['priority'] ?? 'high',
      status: json['status'] ?? 'unread',
      acknowledgedAt: json['acknowledged_at'],
      createdAt: json['created_at'],
    );
  }
}

class SanadDocumentRequestModel {
  int? id;
  int? bookingId;
  int? serviceId;
  String? documentKey;
  String? documentName;
  String? reason;
  String? instructions;
  String? status;
  bool? required;
  String? dueAt;
  String? createdAt;
  Map<String, dynamic>? document;

  SanadDocumentRequestModel({
    this.id,
    this.bookingId,
    this.serviceId,
    this.documentKey,
    this.documentName,
    this.reason,
    this.instructions,
    this.status,
    this.required,
    this.dueAt,
    this.createdAt,
    this.document,
  });

  factory SanadDocumentRequestModel.fromJson(Map<String, dynamic> json) {
    return SanadDocumentRequestModel(
      id: json['id'],
      bookingId: json['booking_id'],
      serviceId: json['service_id'],
      documentKey: json['document_key'],
      documentName: json['document_name'],
      reason: json['reason'],
      instructions: json['instructions'],
      status: json['status'] ?? 'pending',
      required: json['required'] == 1 || json['required'] == true,
      dueAt: json['due_at'],
      createdAt: json['created_at'],
      document: json['document'] is Map ? json['document'] as Map<String, dynamic> : null,
    );
  }
}

class SanadAiInteractionModel {
  int? id;
  String? question;
  String? answer;
  double? confidence;
  bool? requiresEscalation;
  String? status;
  String? createdAt;

  SanadAiInteractionModel({
    this.id,
    this.question,
    this.answer,
    this.confidence,
    this.requiresEscalation,
    this.status,
    this.createdAt,
  });

  factory SanadAiInteractionModel.fromJson(Map<String, dynamic> json) {
    return SanadAiInteractionModel(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      confidence: json['confidence'] != null ? (json['confidence'] as num).toDouble() : null,
      requiresEscalation: json['requires_escalation'] == 1 || json['requires_escalation'] == true,
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}
