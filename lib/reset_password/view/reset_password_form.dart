import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samlibser/reset_password/cubit/reset_password_cubit.dart';
import 'package:formz/formz.dart';

class ResetPasswordForm extends StatelessWidget {
  const ResetPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ResetPasswordCubit, ResetPasswordState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          Navigator.of(context).pop();
        } else if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                  content:
                      Text(state.errorMessage ?? 'Reset Password Failure')),
            );
        }
      },
      child: Align(
        alignment: const Alignment(0, -1 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PasswordInput(),
            const SizedBox(height: 8),
            _ConfirmPasswordInput(),
            const SizedBox(height: 8),
            _ResetPasswordButton(),
          ],
        ),
      ),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: TextField(
              key: const Key('resetPasswordForm_passwordInput_textField'),
              onChanged: (password) =>
                  context.read<ResetPasswordCubit>().passwordChanged(password),
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                helperText: '',
                errorText: state.password.displayError != null
                    ? 'Invalid password'
                    : null,
              ),
            ));
      },
    );
  }
}

class _ConfirmPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.confirmedPassword != current.confirmedPassword,
      builder: (context, state) {
        return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: TextField(
              key: const Key(
                  'resetPasswordForm_confirmedPasswordInput_textField'),
              onChanged: (confirmPassword) => context
                  .read<ResetPasswordCubit>()
                  .confirmedPasswordChanged(confirmPassword),
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm password',
                helperText: '',
                errorText: state.confirmedPassword.displayError != null
                    ? 'Passwords do not match'
                    : null,
              ),
            ));
      },
    );
  }
}

class _ResetPasswordButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
      builder: (context, state) {
        return state.status.isInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('resetPasswordForm_continue_raisedButton'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.orangeAccent,
                ),
                onPressed: state.isValid
                    ? () => context
                        .read<ResetPasswordCubit>()
                        .resetPasswordFormSubmitted()
                    : null,
                child: const Text('RESET PASSWORD'),
              );
      },
    );
  }
}
