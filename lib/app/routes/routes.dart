import 'package:flutter/widgets.dart';
import 'package:samlibser/app/bloc/app_bloc.dart';
import 'package:samlibser/home/view/home.dart';
import 'package:samlibser/login/view/login.dart';

List<Page<dynamic>> onGenerateAppViewPages(
  AppStatus state,
  List<Page<dynamic>> pages,
) {
  switch (state) {
    case AppStatus.authenticated:
      return [HomePage.page()];
    case AppStatus.unauthenticated:
      return [LoginPage.page()];
  }
}