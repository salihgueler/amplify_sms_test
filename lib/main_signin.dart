import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'amplifyconfiguration.dart';

void main() => runApp(const SMSFlowExampleApp());

class SMSFlowExampleApp extends StatelessWidget {
  const SMSFlowExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.orange,
        useMaterial3: true,
      ),
      home: const SignInScreen(),
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final TextEditingController _activationCodeController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _passwordController;

  Future<void> _configureAmplify() async {
    final auth = AmplifyAuthCognito();

    // Use addPlugins function to add more than one Amplify plugins
    await Amplify.addPlugin(auth);

    await Amplify.configure(amplifyconfig);
  }

  @override
  void initState() {
    super.initState();
    _activationCodeController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _activationCodeController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInUser(
    String phoneNumber,
    String password,
  ) async {
    final result = await Amplify.Auth.signIn(
      username: phoneNumber,
      password: password,
    );
    if (result.isSignedIn) {
      debugPrint('Sign in is done.');
    } else {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm the user'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Check your phone number and enter the code below'),
              OutlinedAutomatedNextFocusableTextFormField(
                controller: _activationCodeController,
                padding: const EdgeInsets.only(top: 16),
                labelText: 'Activation Code',
                inputType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Dismiss'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Amplify.Auth.confirmSignIn(
                  confirmationValue: _activationCodeController.text,
                ).then((result) {
                  if (result.isSignedIn) {
                    Navigator.of(context).pop();
                  }
                });
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amplify SMS Flow'),
      ),
      body: FutureBuilder<void>(
          future: _configureAmplify(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView(
                children: [
                  OutlinedAutomatedNextFocusableTextFormField(
                    controller: _phoneNumberController,
                    labelText: 'Phone Number',
                    inputType: TextInputType.phone,
                  ),
                  OutlinedAutomatedNextFocusableTextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    labelText: 'Password',
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        final phoneNumber = _phoneNumberController.text;
                        final password = _passwordController.text;
                        if (phoneNumber.isEmpty || password.isEmpty) {
                          debugPrint(
                              'One of the fields is empty. Not ready to submit.');
                        } else {
                          _signInUser(phoneNumber, password);
                        }
                      },
                      child: const Text('Sign in'),
                    ),
                  ),
                ],
              );
            }
            if (snapshot.hasError) {
              return Text('Some error happened: ${snapshot.error}');
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}

class OutlinedAutomatedNextFocusableTextFormField extends StatelessWidget {
  const OutlinedAutomatedNextFocusableTextFormField({
    this.padding = const EdgeInsets.all(8),
    this.obscureText = false,
    this.labelText,
    this.controller,
    this.inputType,
    Key? key,
  }) : super(key: key);

  final String? labelText;
  final TextEditingController? controller;
  final TextInputType? inputType;
  final EdgeInsets padding;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: inputType,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: labelText,
        ),
      ),
    );
  }
}
