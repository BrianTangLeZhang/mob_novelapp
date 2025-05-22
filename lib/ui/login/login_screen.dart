import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mob_novelapp/nav/navigation.dart';
import 'package:mob_novelapp/secret.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static final supabase = Supabase.instance.client;
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool signUp = false;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _snackbar('Please fill in all fields.');
      return;
    }

    try {
      final res = await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (res.user != null) {
        _snackbar('Logged in successfully');
        if (mounted) {
          context.pushReplacementNamed(Screen.home.name);
        }
      }
    } catch (e) {
      _snackbar('Login failed: ${_formatError(e)}');
    }
  }

  String _formatError(Object e) {
    if (e is AuthException) return e.message;
    return 'Unexpected error';
  }

  void _signUp() async {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _snackbar('Please fill in all fields.');
      return;
    }

    if (_confirmPasswordController.text != _passwordController.text) {
      _snackbar('Passwords do not match.');
      return;
    }

    final res = await supabase.auth.signUp(
      email: _emailController.text,
      password: _passwordController.text,
    );

    final user = res.user;
    if (user != null) {
      await supabase.from('profiles').insert({
        'id': user.id,
        'username': _usernameController.text,
        'email': user.email,
        'role': 'User',
      });

      _snackbar('Signed up successfully');
      setState(() {
        signUp = false;
        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();
      });
    } else if (res.session == null && res.user == null) {
      _snackbar('Sign up failed');
    }
  }

  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) async {
      if (data.event == AuthChangeEvent.signedIn) {
        final user = data.session?.user;
        if (user != null) {
          final profile =
              await supabase
                  .from('profiles')
                  .select()
                  .eq('id', user.id)
                  .maybeSingle();

          if (profile == null) {
            await supabase.from('profiles').insert({
              'id': user.id,
              'username':
                  user.userMetadata?['full_name'] ?? user.email!.split('@')[0],
              'email': user.email,
              'role': 'User',
            });
          }
          if (mounted) {
            context.pushReplacementNamed(Screen.home.name);
          }
        }
      }
    });
  }

  Future<AuthResponse> _googleSignIn() async {
    const clientId = storedClientId;
    final signInOption = GoogleSignIn(serverClientId: clientId);
    final googleUser = await signInOption.signIn();

    if (googleUser == null) {
      _snackbar("Google sign in cancelled.");
    }

    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (idToken == null || accessToken == null) {
      _snackbar("Google authentication failed.");
    }

    final res = await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken!,
      accessToken: accessToken,
    );

    if (res.user != null) {
      _snackbar("Google sign in successful");
    } else {
      _snackbar("Google sign in failed");
    }

    return res;
  }

  void _snackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: 'Novel',
                            style: TextStyle(color: Colors.black),
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'World',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 50),
                    Text(
                      signUp ? 'Sign Up' : 'Login',
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),

                    if (signUp)
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    if (signUp) SizedBox(height: 12),

                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),

                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 12),

                    if (signUp)
                      TextField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2.0,
                            ),
                          ),
                        ),
                        obscureText: true,
                      ),
                    SizedBox(height: 20),

                    FilledButton(
                      onPressed: signUp ? _signUp : _login,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      child: Text(signUp ? 'Sign Up' : 'Login'),
                    ),

                    TextButton(
                      onPressed: () {
                        setState(() {
                          signUp = !signUp;
                        });
                      },
                      child: Text(
                        signUp
                            ? 'Already have an account? Login'
                            : 'Don\'t have an account? Sign Up',
                      ),
                    ),

                    Divider(height: 20),

                    FilledButton.icon(
                      onPressed: _googleSignIn,
                      icon: FaIcon(FontAwesomeIcons.google),
                      label: Text("Sign in with Google"),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(top: 50, left: 0, right: 0, child: Center()),
          ],
        ),
      ),
    );
  }
}
