
abstract class ProfileEvent {}

class ProfileAvatarChangeEvent extends ProfileEvent {
  final String assetName;

  ProfileAvatarChangeEvent({required this.assetName});
}