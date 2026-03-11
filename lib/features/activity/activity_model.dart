// lib/features/activity/activity_model.dart

class ActivityModel {
  final String id;
  final String type;
  final String actorName;
  final String groupId;
  final String groupName;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  ActivityModel({
    required this.id,
    required this.type,
    required this.actorName,
    required this.groupId,
    required this.groupName,
    required this.metadata,
    required this.createdAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    final actor = json['actor'];
    final actorName =
        actor is Map ? (actor['name']?.toString() ?? 'Someone') : 'Someone';

    final group = json['group'];
    final String groupId;
    if (group is Map) {
      groupId = (group['_id'] ?? group['id'] ?? '').toString();
    } else {
      groupId = json['group']?.toString() ?? '';
    }

    // Safely parse createdAt — handles ISO string, or falls back to now
    DateTime createdAt;
    try {
      final raw = json['createdAt'];
      if (raw is String) {
        createdAt = DateTime.parse(raw).toLocal();
      } else if (raw is Map && raw['\$date'] != null) {
        // Mongoose extended JSON format
        createdAt = DateTime.parse(raw['\$date'].toString()).toLocal();
      } else {
        createdAt = DateTime.now();
      }
    } catch (_) {
      createdAt = DateTime.now();
    }

    return ActivityModel(
      id: (json['_id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      actorName: actorName,
      groupId: groupId,
      groupName: (json['groupName'] ?? '').toString(),
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : {},
      createdAt: createdAt,
    );
  }

  String get description {
    final meta = metadata;
    switch (type) {
      case 'expense_added':
        final desc = meta['description']?.toString() ?? 'an expense';
        final rawAmt = meta['amount'];
        final amount =
            rawAmt != null ? '\$${(rawAmt as num).toStringAsFixed(2)}' : '';
        return '$actorName added "$desc"'
            '${amount.isNotEmpty ? ' ($amount)' : ''}';

      case 'expense_updated':
        final desc = meta['description']?.toString() ?? 'an expense';
        return '$actorName updated "$desc"';

      case 'settlement_made':
        final rawAmt = meta['amount'];
        final amount =
            rawAmt != null ? '\$${(rawAmt as num).toStringAsFixed(2)}' : '';
        final to = meta['toName']?.toString() ?? 'someone';
        return '$actorName settled $amount with $to';

      case 'member_added':
        return '$actorName added ${meta['targetName'] ?? 'someone'} to the group';

      case 'member_removed':
        return '$actorName removed ${meta['targetName'] ?? 'someone'} from the group';

      case 'group_created':
        return '$actorName created the group';

      case 'group_renamed':
        final oldName = meta['oldName']?.toString() ?? '';
        final newName = meta['newName']?.toString() ?? '';
        return '$actorName renamed the group'
            '${oldName.isNotEmpty ? ' from "$oldName"' : ''}'
            '${newName.isNotEmpty ? ' to "$newName"' : ''}';

      case 'group_left':
        return '$actorName left the group';

      case 'group_deleted':
        return '$actorName deleted the group';

      default:
        return '$actorName performed an action';
    }
  }
}

class ActivityPagination {
  final int page;
  final int limit;
  final int total;
  final bool hasMore;

  ActivityPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });

  factory ActivityPagination.fromJson(Map<String, dynamic> json) {
    return ActivityPagination(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 30,
      total: (json['total'] as num?)?.toInt() ?? 0,
      hasMore: json['hasMore'] == true,
    );
  }
}
