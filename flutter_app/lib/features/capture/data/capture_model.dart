class CaptureItem {
  final String id;
  final String userId;
  final String content;
  final bool isProcessed;
  final String? destination;   // 'project' | 'objective' | 'habit' | 'ignore'
  final String? destinationId;
  final DateTime createdAt;

  const CaptureItem({
    required this.id,
    required this.userId,
    required this.content,
    required this.isProcessed,
    this.destination,
    this.destinationId,
    required this.createdAt,
  });

  factory CaptureItem.fromJson(Map<String, dynamic> json) => CaptureItem(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        content: json['content'] as String,
        isProcessed: json['is_processed'] as bool? ?? false,
        destination: json['destination'] as String?,
        destinationId: json['destination_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  CaptureItem copyWith({bool? isProcessed, String? destination, String? destinationId}) =>
      CaptureItem(
        id: id,
        userId: userId,
        content: content,
        isProcessed: isProcessed ?? this.isProcessed,
        destination: destination ?? this.destination,
        destinationId: destinationId ?? this.destinationId,
        createdAt: createdAt,
      );
}
