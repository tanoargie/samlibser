import 'package:flutter/widgets.dart';
import 'package:samlibser/account/view/account.dart';
import 'package:samlibser/app/bloc/app_bloc.dart';
import 'package:samlibser/home/view/home.dart';
import 'package:samlibser/login/view/login.dart';

List<Page<dynamic>> onGenerateAppViewPages(
  AppState state,
  List<Page<dynamic>> pages,
) {
  if (state.status == AppStatus.authenticated && state.selectedMenuIndex == 0) {
    return [HomePage.page()];
  } else if (state.status == AppStatus.authenticated &&
      state.selectedMenuIndex == 1) {
    return [AccountPage.page()];
  } else if (state.status == AppStatus.unauthenticated) {
    return [LoginPage.page()];
  } else {
    return [LoginPage.page()];
  }
}

