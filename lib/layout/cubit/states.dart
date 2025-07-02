abstract class SocialStates{}

class SocialInitialState extends SocialStates{}

class SocialGetUserSuccessState extends SocialStates{}

class SocialGetUserLoadingState extends SocialStates{
  SocialGetUserLoadingState(String s);
}

class SocialGetUserErrorState extends SocialStates{

  final String error;

  SocialGetUserErrorState(this.error);
}

class SocialGetAllUsersSuccessState extends SocialStates{}

class SocialGetAllUsersLoadingState extends SocialStates{
 // SocialGetAllUsersLoadingState(String s);
}

class SocialGetAllUsersErrorState extends SocialStates{

  final String error;

  SocialGetAllUsersErrorState(this.error);
}

class SocialChangeBottomNavState extends SocialStates {}

class SocialProfileImagePickedSuccessState extends SocialStates {}

class SocialProfileImagePickedErrorState extends SocialStates {}

class SocialCoverImagePickedSuccessState extends SocialStates {}

class SocialCovereImagePickedErrorState extends SocialStates {}


class SocialUploadProfileImageSuccessState extends SocialStates {}

class SocialUploadProfileImageErrorState extends SocialStates {}

class SocialUploadCoverImageSuccessState extends SocialStates {}

class SocialUploadCoverImageErrorState extends SocialStates {}

class SocialUserUpdateLoadingState extends SocialStates {}


class SocialUserUpdateErrorState extends SocialStates {}

class SocialUserUpdateSuccessState extends SocialStates {}

class SocialSendMessageSuccessState extends SocialStates {}

class SocialSendMessageErrorState extends SocialStates {}

class SocialGetMessageSuccessState extends SocialStates {}

class SocialGetMessageErrorState extends SocialStates {
  final String error;
  SocialGetMessageErrorState(this.error);
}

class SocialUploadStorySuccessState extends SocialStates {}

class SocialUploadStoryErrorState extends SocialStates {}

class SocialUploadStoryLoadingState extends SocialStates {}

class SocialUploadTextStatusSuccessState extends SocialStates {}

class SocialUploadTextStatusErrorState extends SocialStates {}

class SocialUploadTextStatusLoadingState extends SocialStates {}

class SocialGetStoriesSuccessState extends SocialStates {}

class SocialGetStoriesErrorState extends SocialStates {}




