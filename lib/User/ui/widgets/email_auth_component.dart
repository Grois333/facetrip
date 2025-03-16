import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:facetrip/User/repository/cloud_firestore_api.dart';
import 'package:facetrip/widgets/button_green.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class EmailAuthComponent extends StatefulWidget {
  @override
  State<EmailAuthComponent> createState() => _EmailAuthComponentState();
}

class _EmailAuthComponentState extends State<EmailAuthComponent> {
  // Authentication state
  bool _isEmailSigningIn = false;
  bool _isRegistering = false;
  bool _showSignUp = false;

  bool _isResettingPassword = false;
  bool _showResetPassword = false;
  final TextEditingController _resetEmailController = TextEditingController();
  final _resetFormKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _resetEmailController.dispose();
    super.dispose();
  }

  // Show a snackbar with error message
  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Reset password method
  Future<void> _resetPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;

    setState(() {
      _isResettingPassword = true;
    });

    try {
      await firebase_auth.FirebaseAuth.instance.sendPasswordResetEmail(
        email: _resetEmailController.text.trim(),
      );
      
      setState(() {
        _isResettingPassword = false;
        _showResetPassword = false;
      });
      
      // Clear the reset email field
      _resetEmailController.clear();
      
      // Show success message
      _showSnackBar(
        'Password reset email sent. Please check your inbox.', 
        isError: false
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      setState(() {
        _isResettingPassword = false;
      });
      
      if (e.code == 'user-not-found') {
        _showSnackBar('No user found with this email.');
      } else if (e.code == 'invalid-email') {
        _showSnackBar('The email address is not valid.');
      } else {
        _showSnackBar('Password reset error: ${e.message}');
      }
    } catch (e) {
      setState(() {
        _isResettingPassword = false;
      });
      _showSnackBar('An unexpected error occurred.');
      print("Password reset error: $e");
    }
  }

  // Create user document in Firestore
  // In EmailAuthComponent.dart, update the _createUserInFirestore method:
  Future<void> _createUserInFirestore(firebase_auth.User firebaseUser, {String? displayName}) async {
    try {
      final userRef = FirebaseFirestore.instance
          .collection(CloudFirestoreAPI().USERS)
          .doc(firebaseUser.uid);
      
      // Create the user data map with all required fields, including registeredDate
      final userData = {
        'uid': firebaseUser.uid,
        'name': displayName ?? firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? "",
        'email': firebaseUser.email ?? "",
        'photoURL': firebaseUser.photoURL ?? "",
        'myPlaces': [], // Initialize as empty list
        'myFavoritePlaces': [], // Initialize as empty list
        'description': "There is an amazing place in Sri Lanka", // Using the default value from your model
        'registeredDate': FieldValue.serverTimestamp(), // Add this line to include registration date
      };
      
      await userRef.set(userData);
      print("User created in Firestore: ${firebaseUser.uid}");
    } catch (e) {
      print("Error creating user in Firestore: $e");
      throw e; // Re-throw to handle in the calling method
    }
  }

  // Email sign-in method
  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isEmailSigningIn = true;
    });

    try {
      final credential = await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = credential.user;
      if (user != null) {
        if (!user.emailVerified) {
          setState(() {
            _isEmailSigningIn = false;
          });
          _showSnackBar('Please verify your email before signing in.');
          await firebase_auth.FirebaseAuth.instance.signOut();
          return;
        }
        
        print("Signed in with email as: ${user.uid}");
        
        // Check if user exists in Firestore
        bool userExists = false;
        try {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection(CloudFirestoreAPI().USERS)
              .doc(user.uid)
              .get();
          userExists = userDoc.exists;
        } catch (e) {
          print("Error checking user existence: $e");
        }
        
        if (!userExists) {
          // Create user in Firestore if doesn't exist yet
          await _createUserInFirestore(user);
        }
        
        // Set state after successful login
        setState(() {
          _isEmailSigningIn = false;
        });
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      setState(() {
        _isEmailSigningIn = false;
      });
      
      if (e.code == 'user-not-found') {
        _showSnackBar('No user found with this email.');
      } else if (e.code == 'wrong-password') {
        _showSnackBar('Incorrect password.');
      } else if (e.code == 'invalid-credential') {
        _showSnackBar('Invalid email or password.');
      } else {
        _showSnackBar('Sign-in error: ${e.message}');
      }
    } catch (e) {
      setState(() {
        _isEmailSigningIn = false;
      });
      _showSnackBar('An unexpected error occurred.');
      print("Email sign-in error: $e");
    }
  }

  // Email registration method
  Future<void> _registerWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isRegistering = true;
    });

    try {
      final credential = await firebase_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = credential.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(_nameController.text.trim());

        // Send verification email
        await user.sendEmailVerification();

        // Create user in Firestore
        await _createUserInFirestore(user, displayName: _nameController.text.trim());

        setState(() {
          _isRegistering = false;
          _showSignUp = false;
        });

        // Show success Snackbar
        _showSnackBar('Registration successful! Please check your email to verify your account before logging in.');

        // Sign out the user to prevent automatic navigation
        await firebase_auth.FirebaseAuth.instance.signOut();
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      setState(() {
        _isRegistering = false;
      });

      if (e.code == 'weak-password') {
        _showSnackBar('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        _showSnackBar('An account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        _showSnackBar('The email address is not valid.');
      } else {
        _showSnackBar('Registration error: ${e.message}');
      }
    } catch (e) {
      setState(() {
        _isRegistering = false;
      });
      _showSnackBar('An unexpected error occurred.');
      print("Email registration error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Reset password UI
    if (_showResetPassword) {
      return Container(
        width: screenWidth * 0.85,
        margin: EdgeInsets.only(bottom: 20),
        child: Form(
          key: _resetFormKey,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 15),
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _resetEmailController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email, color: Colors.blue),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
              
              ButtonGreen(
                text: 'Send Reset Email',
                onPressed: _isResettingPassword ? () {} : () => _resetPassword(),
                width: 300.0,
                height: 50.0,
              ),
              
              if (_isResettingPassword)
                Container(
                  margin: EdgeInsets.only(top: 15),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              
              SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showResetPassword = false;
                    _resetEmailController.clear();
                  });
                },
                child: Text(
                  "Back to Login",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Container(
      width: screenWidth * 0.85,
      margin: EdgeInsets.only(bottom: 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 15),
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email, color: Colors.blue),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 15),
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: Colors.blue),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (_showSignUp && value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ),
            if (_showSignUp) ...[
              Container(
                margin: EdgeInsets.only(bottom: 15),
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.blue),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 15),
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Full Name',
                    prefixIcon: Icon(Icons.person, color: Colors.blue),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
              ),
            ],
            
            // Replace ElevatedButton with ButtonGreen to maintain consistent styling
            ButtonGreen(
              text: _showSignUp ? 'Sign Up' : 'Login',
              onPressed: () {
                // Only execute if not currently signing in or registering
                if (!_isEmailSigningIn && !_isRegistering) {
                  if (_showSignUp) {
                    _registerWithEmail();
                  } else {
                    _signInWithEmail();
                  }
                }
              },
              width: 300.0,
              height: 50.0,
              // You might need to add a disabled property to your ButtonGreen widget
              // If ButtonGreen has this property, you can use it like this:
              // disabled: _isEmailSigningIn || _isRegistering,
            ),

            if (_isEmailSigningIn || _isRegistering)
              Container(
                margin: EdgeInsets.only(top: 15),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            SizedBox(height: 15),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showSignUp = !_showSignUp;
                  _formKey.currentState?.reset();
                });
              },
              child: Text(
                _showSignUp ? "Already have an account? Login" : "Don't have an account? Sign up",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 15),
            if (!_showSignUp) // Only show on login screen
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showResetPassword = true;
                  });
                },
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

          ],
        ),
      ),
    );
  }
}