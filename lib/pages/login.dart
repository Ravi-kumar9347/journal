import 'package:flutter/material.dart';
import 'package:journal/blocs/login_bloc.dart';
import 'package:journal/services/authentication.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late LoginBloc _loginBloc;

  @override
  initState() {
    super.initState();
    _loginBloc = LoginBloc(AuthenticationService());
  }

  @override
  void dispose() {
    _loginBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: Icon(
            Icons.account_circle,
            size: 88,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.only(top: 16, right: 32, bottom: 16, left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StreamBuilder(
                stream: _loginBloc.email,
                builder: (context, snapshot) {
                  return TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      icon: const Icon(Icons.mail_outline),
                      errorText: snapshot.error?.toString(),
                    ),
                    onChanged: _loginBloc.emailChanged.add,
                  );
                },
              ),
              StreamBuilder(
                stream: _loginBloc.password,
                builder: (context, snapshot) {
                  return TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      icon: const Icon(
                        Icons.security,
                      ),
                      errorText: snapshot.error?.toString(),
                    ),
                    onChanged: _loginBloc.passwordChanged.add,
                  );
                },
              ),
              const SizedBox(
                height: 48,
              ),
              _buildLoginAndCreateButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginAndCreateButtons() {
    return StreamBuilder(
        initialData: 'Login',
        stream: _loginBloc.loginOrCreateButton,
        builder: (context, snapshot) {
          print(snapshot.data);
          if (snapshot.data == 'Login') {
            return _buttonsLogin();
          } else if (snapshot.data == 'create Account') {
            return _buttonsCreateAccount();
          } else {
            return Container();
          }
        });
  }

  Column _buttonsLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StreamBuilder(
          initialData: false,
          stream: _loginBloc.enableLoginCreateButton,
          builder: (context, snapshot) {
            return ElevatedButton(
              style: ButtonStyle(
                  elevation: MaterialStateProperty.resolveWith((states) => 16),
                  backgroundColor: MaterialStateColor.resolveWith((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.grey.shade100;
                    } else {
                      return Colors.lightGreen.shade200;
                    }
                  })),
              onPressed: snapshot.data ?? false
                  ? () => _loginBloc.loginOrCreateChange.add('Login')
                  : () {},
              child: const Text('Login'),
            );
          },
        ),
        TextButton(
          child: const Text('Create Account'),
          onPressed: () {
            _loginBloc.loginOrCreateButtonChanged.add('create Account');
          },
        ),
      ],
    );
  }

  Column _buttonsCreateAccount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StreamBuilder(
          initialData: false,
          stream: _loginBloc.enableLoginCreateButton,
          builder: (context, snapshot) {
            return ElevatedButton(
                style: ButtonStyle(
                    elevation: MaterialStateProperty.all(16),
                    backgroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey.shade100;
                      } else {
                        return Colors.lightGreen.shade200;
                      }
                    })),
                onPressed: snapshot.data ?? false
                    ? () => _loginBloc.loginOrCreateChange.add('create Account')
                    : () {},
                child: const Text('Create Account'));
          },
        ),
        TextButton(
            onPressed: () {
              _loginBloc.loginOrCreateButtonChanged.add('Login');
            },
            child: const Text('Login'))
      ],
    );
  }
}
