/// User model — data layer representation with JSON serialization.
library;

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.createdAt,
    super.lastLogin,
    super.cyberHealthScore,
    super.isEmailVerified,
  });

  /// Create from Firestore document.
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['createdAt'] as dynamic).millisecondsSinceEpoch as int)
          : null,
      lastLogin: map['lastLogin'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['lastLogin'] as dynamic).millisecondsSinceEpoch as int)
          : null,
      cyberHealthScore:
          (map['cyberHealthScore'] as num?)?.toDouble() ?? 50.0,
      isEmailVerified: map['isEmailVerified'] as bool? ?? false,
    );
  }

  /// Convert to Firestore map.
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'cyberHealthScore': cyberHealthScore,
      'isEmailVerified': isEmailVerified,
      'lastLogin': DateTime.now(),
    };
  }

  /// Create from UserEntity.
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
      lastLogin: entity.lastLogin,
      cyberHealthScore: entity.cyberHealthScore,
      isEmailVerified: entity.isEmailVerified,
    );
  }
}
