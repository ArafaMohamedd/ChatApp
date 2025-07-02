import 'package:bloc/bloc.dart';
import 'package:chatnew/core/utils/widgets/cubit/states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialstate()); // تم تصحيح super و AppInitialState

  static AppCubit get(context) => BlocProvider.of(context); // دالة ثابتة للحصول على الـ Cubit
}