class Message {
  final String messageId;
  final String practitionerId;
  final String userId;
  final String subject;
  final String body;
  final bool isRead;
  final DateTime sentAt;
  final DateTime? readAt;

  Message({
    required this.messageId,
    required this.practitionerId,
    required this.userId,
    required this.subject,
    required this.body,
    required this.isRead,
    required this.sentAt,
    this.readAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['message_id'],
      practitionerId: json['practitioner_id'],
      userId: json['user_id'],
      subject: json['subject'],
      body: json['body'],
      isRead: json['is_read'],
      sentAt: DateTime.parse(json['sent_at']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'practitioner_id': practitionerId,
      'user_id': userId,
      'subject': subject,
      'body': body,
      'is_read': isRead,
      'sent_at': sentAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }
}