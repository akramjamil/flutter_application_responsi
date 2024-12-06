import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../screens/home_page.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final String _correctUsername = 'akram';
  final String _correctPassword = '12345';

  bool _showPassword = false; 
  bool _rememberMe = false; 

  final _key = encrypt.Key.fromUtf8('my 32 length key................');
  final _iv = encrypt.IV.fromLength(16);

  late encrypt.Encrypter
      _encrypter; 

  @override
  void initState() {
    super.initState();
    _encrypter = encrypt.Encrypter(encrypt.AES(_key));
  }

  void _login() async {
    final username = _usernameController.text;
    final encryptedUsername =
        _encrypter.encrypt(username, iv: _iv).base64; 
    print('Original username: $username');
    print('Encrypted username: $encryptedUsername'); 

    final password = _passwordController.text;

    if (encryptedUsername ==
            _encrypter.encrypt(_correctUsername, iv: _iv).base64 &&
        password == _correctPassword) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString(
          'username', encryptedUsername); 
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Username or Password is incorrect'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Welcome')),
        backgroundColor: const Color.fromARGB(255, 35, 240, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              Center(
                child: Image.asset('assets/logo4.png',
                    height: 500), 
              ),
              SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(), // Outlined border
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 10.0), // Padding
                ),
                style: GoogleFonts.poppins(), // Change font to Poppins
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(), // Outlined border
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 10.0), // Padding
                ),
                obscureText: !_showPassword, // Toggle password visibility
                style: GoogleFonts.poppins(), // Change font to Poppins
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) =>
                            setState(() => _rememberMe = value!),
                      ),
                      Text('Remember Me',
                          style:
                              GoogleFonts.poppins()), // Change font to Poppins
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              OutlinedButton(
                onPressed: _login,
                child: Center(
                  child: Text(
                    'Login',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: EdgeInsets.all(22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}