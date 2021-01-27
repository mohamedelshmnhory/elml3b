import 'dart:convert';

class AppEvent {
  final String title;
  final String fieldName;
  final String hourPrice;
  final String players;
  final String needPlayers;
  final String userPhone;
  final String id;
  final String description;
  final DateTime date;
  final DateTime start;
  final DateTime end;
  final String userId;
  final String managerId;
  final bool confirmed;
  final String photo;

  AppEvent({
    this.fieldName,
    this.hourPrice,
    this.players,
    this.needPlayers,
    this.userPhone,
    this.title,
    this.id,
    this.description,
    this.date,
    this.start,
    this.end,
    this.userId,
    this.managerId,
    this.confirmed,
    this.photo
  });

  AppEvent copyWith({
    String title,
    String fieldName,
    String hourPrice,
    String players,
    String needPlayers,
    String userPhone,
    String id,
    String description,
    DateTime date,
    DateTime start,
    DateTime end,
    String userId,
    String managerId,
    bool public,
    String photo,
  }) {
    return AppEvent(
      title: title ?? this.title,
      fieldName: fieldName ?? this.fieldName,
      hourPrice: hourPrice ?? this.hourPrice,
      players: players ?? this.players,
      needPlayers: needPlayers ?? this.needPlayers,
      userPhone: userPhone ?? this.userPhone,
      id: id ?? this.id,
      description: description ?? this.description,
      date: date ?? this.date,
      start: start ?? this.start,
      end: end ?? this.end,
      userId: userId ?? this.userId,
      managerId: managerId ?? this.managerId,
      confirmed: public ?? this.confirmed,
      photo: photo ?? this.photo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'fieldName': fieldName,
      'hourPrice': hourPrice,
      'players': players,
      'needPlayers': needPlayers,
      'userPhone': userPhone,
      'id': id,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
      'userId': userId,
      'managerId': managerId,
      'public': confirmed,
      'photo': photo,
    };
  }

  factory AppEvent.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return AppEvent(
      title: map['title'],
      fieldName: map['fieldName'],
      hourPrice: map['hourPrice'],
      players: map['players'],
      needPlayers: map['needPlayers'],
      userPhone: map['userPhone'],
      id: map['id'],
      description: map['description'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      start: DateTime.fromMillisecondsSinceEpoch(map['start']),
      end: DateTime.fromMillisecondsSinceEpoch(map['end']),
      userId: map['userId'],
      managerId: map['managerId'],
      confirmed: map['confirmed'],
      photo: map['photo'],
    );
  }
  factory AppEvent.fromDS(String id, Map<String, dynamic> data) {
    if (data == null) return null;
    return AppEvent(
      title: data['title'],
      fieldName: data['fieldName'],
      hourPrice: data['hourPrice'],
      players: data['players'],
      needPlayers: data['needPlayers'],
      userPhone: data['userPhone'],
      id: id,
      description: data['description'],
      date: DateTime.fromMillisecondsSinceEpoch(data['date']),
      start: DateTime.fromMillisecondsSinceEpoch(data['start']),
      end: DateTime.fromMillisecondsSinceEpoch(data['end']),
      userId: data['userId'],
      managerId: data['managerId'],
      confirmed: data['confirmed'],
      photo: data['photo'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AppEvent.fromJson(String source) =>
      AppEvent.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AppEvent(title: $title, id: $id, description: $description, date: $date, start: $start, end: $end, userId: $userId,managerId: $managerId, confirmed: $confirmed)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is AppEvent &&
        o.title == title &&
        o.id == id &&
        o.description == description &&
        o.date == date &&
        o.start == start &&
        o.end == end &&
        o.userId == userId &&
        o.managerId == managerId &&
        o.confirmed == confirmed;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        id.hashCode ^
        description.hashCode ^
        date.hashCode ^
        start.hashCode ^
        end.hashCode ^
        userId.hashCode ^
        managerId.hashCode ^
        confirmed.hashCode;
  }
}
