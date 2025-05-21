import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mob_novelapp/nav/navigation.dart';
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

    final res = await supabase.auth.signInWithPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (res.user != null) {
      _snackbar('Logged in successfully');
    } else {
      _snackbar('Login failed');
    }
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
              'role': 'user',
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
    const clientId =
        "686459249620-e3f0cvj9pj2e6samtun9elg4pomu6030.apps.googleusercontent.com";
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Novel World",
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 60.0),
              Text(
                signUp ? 'Sign Up' : 'Login',
                style: TextStyle(fontSize: 24.0),
              ),
              if (signUp)
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              if (signUp)
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                ),
              SizedBox(height: 20),
              FilledButton(
                onPressed: signUp ? _signUp : _login,
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
              Divider(),
              FilledButton.icon(
                onPressed: _googleSignIn,
                icon: FaIcon(FontAwesomeIcons.google),
                label: Text("Sign in with Google"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
