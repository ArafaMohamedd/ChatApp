import 'package:chatnew/core/utils/components.dart';
import 'package:chatnew/layout/cubit/cubit.dart';
import 'package:chatnew/layout/cubit/states.dart';
import 'package:chatnew/models/social_app/social_user_model.dart';
import 'package:chatnew/modules/social_app/chat_details/chat_details_screen.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return ConditionalBuilder(
          condition: SocialCubit.get(context).users.length > 0,
          builder: (context) => ListView.separated(
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) => buildChatItem(
              SocialCubit.get(context).users[index],
              context, // Pass context here
            ),
            separatorBuilder: (context, index) => mydivider(),
            itemCount: SocialCubit.get(context).users.length,
          ),
          fallback: (context) => Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget buildChatItem(SocialUserModel model, BuildContext context) => InkWell(
    onTap: () {
      // Navigate to ChatDetailsScreen when tapped
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatDetailsScreen(userModel: model),
        ),
      );
    },
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.0,
            backgroundImage: NetworkImage('${model.image}'),
          ),
          SizedBox(width: 15.0),
          Text('${model.name}'),
        ],
      ),
    ),
  );
}