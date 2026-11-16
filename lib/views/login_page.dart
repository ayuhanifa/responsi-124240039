import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  

  bool isLogin = true; 


  void _register() async {
    if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      

      await prefs.setString('reg_username', _usernameController.text);
      await prefs.setString('reg_password', _passwordController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registrasi Berhasil! Silakan Login.'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        isLogin = true;
        _usernameController.clear();
        _passwordController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username dan Password tidak boleh kosong')),
      );
    }
  }

  void _login() async {
    if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
 
      String? registeredUser = prefs.getString('reg_username');
      String? registeredPass = prefs.getString('reg_password');

    
      if ((registeredUser == _usernameController.text && registeredPass == _passwordController.text) || registeredUser == null) {
        

        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', _usernameController.text);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Username atau Password salah!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username dan Password harus diisi!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? "Login Page" : "Register Page"), // Judul berubah dinamis
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isLogin ? Icons.rocket : Icons.app_registration, size: 80, color: Colors.brown),
            SizedBox(height: 20),
            Text(
              isLogin ? "LOGIN SPACEFLIGHT" : "REGISTER AKUN BARU",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLogin ? _login : _register, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown, 
                  foregroundColor: Colors.white
                ),
                child: Text(isLogin ? 'LOGIN' : 'REGISTER'),
              ),
            ),
            
            SizedBox(height: 10),
            
   
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin; 
                });
              },
              child: Text(
                isLogin 
                  ? "Belum punya akun? Daftar disini" 
                  : "Sudah punya akun? Login disini",
                style: TextStyle(color: Colors.brown),
              ),
            ),
          ],
        ),
      ),
    );
  }
}