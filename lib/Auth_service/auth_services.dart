import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Get user document from Firestore
  Future<DocumentSnapshot> getUserDocument(String uid) async {
    try {
      return await _firestore.collection('Users').doc(uid).get();
    } catch (e) {
      throw Exception("Failed to get user document: ${e.toString()}");
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception("Failed to sign in: ${e.toString()}");
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception("Failed to sign out: ${e.toString()}");
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(String email, String password, String name, String photoUrl) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'photoUrl': photoUrl,
      });

      // Update FirebaseAuth profile
      await userCredential.user!.updateProfile(displayName: name, photoURL: photoUrl);

      return userCredential;
    } catch (e) {
      throw Exception("Failed to sign up: ${e.toString()}");
    }
  }

  // Update user information in Firestore
  Future<void> updateUserInfo(String uid, {String? email, String? name, String? photoUrl}) async {
    try {
      final updates = <String, dynamic>{};
      if (email != null) updates['email'] = email;
      if (name != null) updates['name'] = name;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      // Update Firestore
      await _firestore.collection('Users').doc(uid).update(updates);

      // Also update FirebaseAuth profile if name or photoUrl is updated
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateProfile(displayName: name, photoURL: photoUrl);
        // Ensure that FirebaseAuth reflects the changes
        await user.reload();
      }
    } catch (e) {
      throw Exception("Failed to update user info: ${e.toString()}");
    }
  }

  // Update user password
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }

      // Re-authenticate user with current password
      AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } catch (e) {
      throw Exception("Failed to update password: ${e.toString()}");
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception("Failed to send password reset email: ${e.toString()}");
    }
  }

  // Method to delete a user document from Firestore
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('Users').doc(userId).delete();
    } catch (e) {
      throw Exception("Failed to delete user: ${e.toString()}");
    }
  }
}
