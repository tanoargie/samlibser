import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:samlibser/app/bloc/app_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samlibser/login/view/login.dart';
import 'package:samlibser/reset_password/view/reset_password_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  static Page<void> page() {
    return const MaterialPage<void>(child: AccountPage());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    final username = user.name ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        actions: <Widget>[
          IconButton(
              key: const Key('accountPage_logout_iconButton'),
              icon: const Icon(Icons.exit_to_app),
              onPressed: () =>
                  context.read<AppBloc>().add(const AppLogoutRequested()))
        ],
      ),
      body: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text('Hello $username',
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                // OutlinedButton(
                //     style: const ButtonStyle(
                //         fixedSize: MaterialStatePropertyAll(Size.infinite)),
                //     onPressed: () {},
                //     child: const Row(
                //       mainAxisAlignment: MainAxisAlignment.start,
                //       children: [
                //         Icon(Icons.account_box),
                //         Padding(
                //           padding: EdgeInsets.symmetric(horizontal: 12),
                //           child: Text(
                //             'Personal Info',
                //           ),
                //         ),
                //         Spacer(),
                //         Icon(Icons.arrow_right),
                //       ],
                //     )),
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black87,
                    ),
                    onPressed: () => Navigator.of(context)
                        .push<void>(ResetPasswordPage.route()),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.lock),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Reset Password',
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_right),
                      ],
                    )),
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black87,
                    ),
                    onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Text('Are you sure?'),
                                  const SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context
                                              .read<AuthenticationRepository>()
                                              .deleteAccount();
                                          Navigator.of(context)
                                              .push<void>(LoginPage.route());
                                        },
                                        child: const Text('Yes'),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.delete),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Delete Account',
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_right),
                      ],
                    )),
              ])
            ],
          )),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Account',
            ),
          ],
          currentIndex: context.read<AppBloc>().state.selectedMenuIndex,
          selectedItemColor: Colors.amber[800],
          onTap: (int newIndex) =>
              context.read<AppBloc>().add(AppSelectedIndex(newIndex))),
    );
  }
}
