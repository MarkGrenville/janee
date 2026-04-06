import 'package:cloud_firestore/cloud_firestore.dart';

class AppModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String imageUrl;
  final String coverColor;
  final String ownerId;
  final bool isPublic;
  final String responseType;
  final String webhookUrl;
  final int subscriberCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppModel({
    required this.id,
    required this.name,
    this.description = '',
    this.icon = '📋',
    this.imageUrl = '',
    this.coverColor = '',
    required this.ownerId,
    this.isPublic = false,
    this.responseType = 'yes_no',
    this.webhookUrl = '',
    this.subscriberCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory AppModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? '📋',
      imageUrl: data['imageUrl'] ?? '',
      coverColor: data['coverColor'] ?? '',
      ownerId: data['ownerId'] ?? '',
      isPublic: data['isPublic'] ?? false,
      responseType: data['responseType'] ?? 'yes_no',
      webhookUrl: data['webhookUrl'] ?? '',
      subscriberCount: data['subscriberCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'imageUrl': imageUrl,
      'coverColor': coverColor,
      'ownerId': ownerId,
      'isPublic': isPublic,
      'responseType': responseType,
      'webhookUrl': webhookUrl,
      'subscriberCount': subscriberCount,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class CardModel {
  final String id;
  final String appId;
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final String linkUrl;
  final String icon;
  final String status;
  final String webhookUrl;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;
  final DateTime? availableSince;
  final String createdBy;

  CardModel({
    required this.id,
    required this.appId,
    required this.title,
    this.subtitle = '',
    this.description = '',
    this.imageUrl = '',
    this.linkUrl = '',
    this.icon = '',
    this.status = 'active',
    this.webhookUrl = '',
    this.metadata = const {},
    this.createdAt,
    this.availableSince,
    this.createdBy = '',
  });

  factory CardModel.fromFirestore(DocumentSnapshot doc, {required String appId}) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CardModel(
      id: doc.id,
      appId: appId,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      linkUrl: data['linkUrl'] ?? '',
      icon: data['icon'] ?? '',
      status: data['status'] ?? 'active',
      webhookUrl: data['webhookUrl'] ?? '',
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      availableSince: (data['availableSince'] as Timestamp?)?.toDate(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'icon': icon,
      'status': status,
      'webhookUrl': webhookUrl,
      'metadata': metadata,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'availableSince': availableSince != null ? Timestamp.fromDate(availableSince!) : FieldValue.serverTimestamp(),
      'createdBy': createdBy,
    };
  }
}

class DecisionModel {
  final String id;
  final String appId;
  final String cardId;
  final String cardTitle;
  final String decision;
  final DateTime? decidedAt;
  final DateTime? availableSince;
  final int? timeToDecisionMs;
  final bool webhookFired;

  DecisionModel({
    required this.id,
    required this.appId,
    required this.cardId,
    this.cardTitle = '',
    required this.decision,
    this.decidedAt,
    this.availableSince,
    this.timeToDecisionMs,
    this.webhookFired = false,
  });

  factory DecisionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return DecisionModel(
      id: doc.id,
      appId: data['appId'] ?? '',
      cardId: data['cardId'] ?? '',
      cardTitle: data['cardTitle'] ?? '',
      decision: data['decision'] ?? '',
      decidedAt: (data['decidedAt'] as Timestamp?)?.toDate(),
      availableSince: (data['availableSince'] as Timestamp?)?.toDate(),
      timeToDecisionMs: data['timeToDecisionMs'],
      webhookFired: data['webhookFired'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'appId': appId,
      'cardId': cardId,
      'cardTitle': cardTitle,
      'decision': decision,
      'decidedAt': FieldValue.serverTimestamp(),
      'availableSince': availableSince != null ? Timestamp.fromDate(availableSince!) : null,
      'timeToDecisionMs': timeToDecisionMs,
      'webhookFired': webhookFired,
    };
  }
}
