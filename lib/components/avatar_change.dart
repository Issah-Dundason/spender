import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/profile/profile_event.dart';

import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_state.dart';
import 'avatar_profile.dart';

class AvatarChanger extends StatelessWidget {
  const AvatarChanger({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        var avatars = state.optionalAvatars.toList();
        return Row(
          children: [
            AvatarProfile(
              assetName: state.currentAvatar,
              avatarWidth: 90,
              avatarHeight: 90,
              backColor: Colors.white70,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) =>
                        GestureDetector(
                          onTap: () {
                            context.read<ProfileBloc>().add(ProfileAvatarChangeEvent(assetName: avatars[index]));
                          },
                          child: AvatarProfile(
                            assetName: avatars[index],
                              avatarHeight: 60,
                              avatarWidth: 60,
                              backColor: Theme.of(context).colorScheme.secondary),
                        ),
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(width: 10),
                    itemCount: state.optionalAvatars.length),
              ),
            ),
          ],
        );
      },
    );
  }
}
