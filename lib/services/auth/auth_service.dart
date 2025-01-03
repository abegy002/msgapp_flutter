import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

Future<UserCredential> signInWithEmailPassword(
  String email,
  String password,
) async {
  try {
    // Sign in the user
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update the user's Firestore document (use 'merge' to avoid overwriting)
    await _firestore.collection("Users").doc(userCredential.user!.uid).set({
      'uid': userCredential.user!.uid,
      'email': email,
    }, SetOptions(merge: true)); // Merge to prevent overwriting existing data

    return userCredential;
  } on FirebaseAuthException catch (e) {
    throw Exception(e.code);
  }
}


  Future<void> signOut() async {
    return await _auth.signOut();
  }

  Future<UserCredential> signUpWithEmailPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> editProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection("Users").doc(user.uid).update({
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
        });
      } catch (e) {
        throw Exception("Failed to update profile: $e");
      }
    } else {
      throw Exception("User not authenticated");
    }
  }

}
