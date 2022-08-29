import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<String> {
  AuthCubit() : super("");

  void signIn(String token) => emit(token);

  void signOut() => emit("");
}
