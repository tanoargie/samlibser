import 'package:flutter/material.dart';
import 'package:samlibser/app/bloc/app_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  static Page<void> page() {
    return const MaterialPage<void>(child: AccountPage());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);

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
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 4),
            Text(user.email ?? ''),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books),
              label: 'Library',
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
