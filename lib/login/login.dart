import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_de_ticket/login/redirectionApresLogin.dart';
import '../couleur/couleur.dart';
import 'forgot.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscure3 = true;
  bool visible = false;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: Couleurs.premierCouleur,
                    child: Center(
                      child: Container(
                        margin: EdgeInsets.all(12),
                        child: Form(
                          key: _formkey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Logo en haut de la page
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Image.asset(
                                  'assets/images/logoTicket.png', // Chemin de l'image dans votre dossier assets
                                  width: 350,
                                  height: 350,
                                ),
                              ),

                              // Champ de texte pour l'email
                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Email',
                                  enabled: true,
                                  contentPadding: const EdgeInsets.only(
                                      left: 14.0, bottom: 8.0, top: 8.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Email cannot be empty";
                                  }
                                  if (!RegExp(
                                          "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                      .hasMatch(value)) {
                                    return "Please enter a valid email";
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (value) {
                                  emailController.text = value!;
                                },
                                keyboardType: TextInputType.emailAddress,
                              ),
                              SizedBox(height: 20),

                              // Champ de texte pour le mot de passe
                              TextFormField(
                                controller: passwordController,
                                obscureText: _isObscure3,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    icon: Icon(_isObscure3
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        _isObscure3 = !_isObscure3;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Password',
                                  enabled: true,
                                  contentPadding: const EdgeInsets.only(
                                      left: 14.0, bottom: 8.0, top: 15.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  RegExp regex = RegExp(r'^.{6,}$');
                                  if (value!.isEmpty) {
                                    return "Password cannot be empty";
                                  }
                                  if (!regex.hasMatch(value)) {
                                    return "Please enter valid password (min. 6 characters)";
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (value) {
                                  passwordController.text = value!;
                                },
                                keyboardType: TextInputType.visiblePassword,
                              ),
                              SizedBox(height: 20),

                              // Bouton "Forgot Password"
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Couleurs.premierCouleur,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => Forgotpass()),
                                  );
                                },
                                child: Text(
                                  "Mot de passe oublié ....",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),

                              // Bouton "Login"
                              MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                elevation: 5.0,
                                height: 40,
                                onPressed: () {
                                  setState(() {
                                    visible = true;
                                  });
                                  signIn(emailController.text,
                                      passwordController.text);
                                },
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Couleurs.premierCouleur),
                                ),
                                color: Colors.white,
                              ),
                              SizedBox(height: 10),

                              // Indicateur de chargement
                              Visibility(
                                maintainSize: true,
                                maintainAnimation: true,
                                maintainState: true,
                                visible: visible,
                                child: Container(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signIn(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Obtenez l'UID de l'utilisateur créé
        String uid = userCredential.user!.uid;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RedirectionApresLogin()),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
        }
      }
    }
  }
}
