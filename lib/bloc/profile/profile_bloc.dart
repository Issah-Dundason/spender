import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spender/bloc/profile/profile_event.dart';
import 'package:spender/bloc/profile/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<ProfileAvatarChangeEvent>(_onProfileAvatarChange);
  }

  _onProfileAvatarChange(
    ProfileAvatarChangeEvent e,
    Emitter<ProfileState> emitter,
  ) async {

    String currentAssetName = e.assetName;

    //save to shared preference
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("profile/avatar", currentAssetName);

    var newOptions = avatars.where((a) => a != currentAssetName).toSet();

    emitter(ProfileState(
      currentAvatar: currentAssetName,
      optionalAvatars: newOptions,
    ));
  }
}
