import 'package:bloc/bloc.dart';
import 'package:spender/bloc/profile/profile_event.dart';
import 'package:spender/bloc/profile/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileState()) {
    on<ProfileAvatarChangeEvent>(_onProfileAvatarChange);
  }

  _onProfileAvatarChange(
      ProfileAvatarChangeEvent e, Emitter<ProfileState> emitter) {
    String currentAssetName = e.assetName;
    //To do
    //save to shared preference
    var newOptions = avatars.where((a) => a != currentAssetName).toSet();
    emitter(ProfileState(
        currentAvatar: currentAssetName, optionalAvatars: newOptions));
  }
}
