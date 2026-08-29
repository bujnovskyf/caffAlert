class Profile {
  const Profile({
    required this.id,
    this.displayName,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      displayName: json['display_name'] as String?,
    );
  }

  final String id;
  final String? displayName;
}
