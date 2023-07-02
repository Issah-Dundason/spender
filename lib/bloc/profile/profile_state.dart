import 'package:equatable/equatable.dart';

var avatars = {
  'girlteen.svg',
  'housewife.svg',
  'muslim.svg',
  'nurse.svg',
  'officeLady.svg',
  'tracker.svg',
  'womanengineer.svg',
  'workerman.svg'
};

class ProfileState extends Equatable {
  final String currentAvatar;
  final Set<String> optionalAvatars;

  const ProfileState({
    this.currentAvatar = 'housewife.svg',
    this.optionalAvatars = const {},
  });

  @override
  List<Object?> get props => [currentAvatar, optionalAvatars];
}
