import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<void> _saveUserToFirestore(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();

      final now = DateTime.now();

      if (!docSnapshot.exists) {
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          createdAt: now,
          lastSignIn: now,
          gender: 'Not set',
          dateOfBirth: 'Not set',
          avatarId: '6',
          hasPassword: false,
          phoneNumber: null, // Initialize phone number as null
        );

        await userDoc.set(userModel.toMap());
      } else {
        await userDoc.update({
          'lastSignIn': now.toIso8601String(),
          'displayName': user.displayName ?? '',
        });
      }
    } catch (e) {
      print('Error saving user to Firestore: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? gender,
    String? dateOfBirth,
    String? avatarId,
  }) async {
    try {
      final userDoc = _firestore.collection('users').doc(uid);
      final updateData = <String, dynamic>{};

      if (displayName != null) updateData['displayName'] = displayName;
      if (gender != null) updateData['gender'] = gender;
      if (dateOfBirth != null) updateData['dateOfBirth'] = dateOfBirth;
      if (avatarId != null) updateData['avatarId'] = avatarId;

      await userDoc.update(updateData);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Phone number related methods
  Future<bool> savePhoneNumber(String phoneNumber) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _firestore.collection('users').doc(user.uid).update({
        'phoneNumber': phoneNumber,
        'phoneNumberAddedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error saving phone number: $e');
      return false;
    }
  }

  Future<bool> isPhoneNumberExists(String phoneNumber) async {
    try {
      final user = currentUser;
      if (user == null) return false;

      // Query all users to check if phone number already exists
      final querySnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      // If phone number exists and belongs to a different user
      for (var doc in querySnapshot.docs) {
        if (doc.id != user.uid) {
          return true; // Phone number exists with different user
        }
      }

      return false; // Phone number doesn't exist or belongs to current user
    } catch (e) {
      print('Error checking phone number existence: $e');
      return false;
    }
  }

  Future<bool> hasPhoneNumber() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        final phoneNumber = data?['phoneNumber'];
        return phoneNumber != null && phoneNumber.toString().isNotEmpty;
      }
      return false;
    } catch (e) {
      print('Error checking if user has phone number: $e');
      return false;
    }
  }

  Future<String?> getUserPhoneNumber() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        return data?['phoneNumber'];
      }
      return null;
    } catch (e) {
      print('Error getting user phone number: $e');
      return null;
    }
  }

  Future<bool> updatePhoneNumber(String newPhoneNumber) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if new phone number already exists with another user
      final phoneExists = await isPhoneNumberExists(newPhoneNumber);
      if (phoneExists) {
        throw Exception('Phone number already exists with another account');
      }

      await _firestore.collection('users').doc(user.uid).update({
        'phoneNumber': newPhoneNumber,
        'phoneNumberUpdatedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error updating phone number: $e');
      return false;
    }
  }

  // Hash password for security
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Save password to Firebase
  Future<bool> savePassword(String password) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final hashedPassword = _hashPassword(password);

      await _firestore.collection('users').doc(user.uid).update({
        'password': hashedPassword,
        'passwordSetAt': DateTime.now().toIso8601String(),
        'hasPassword': true,
      });

      return true;
    } catch (e) {
      print('Error saving password: $e');
      return false;
    }
  }

  // Check if password is already set
  Future<bool> isPasswordSet() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        return data?['hasPassword'] == true;
      }
      return false;
    } catch (e) {
      print('Error checking password status: $e');
      return false;
    }
  }

  // Verify password
  Future<bool> verifyPassword(String password) async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        final storedPassword = data?['password'];
        if (storedPassword != null) {
          final hashedInputPassword = _hashPassword(password);
          return hashedInputPassword == storedPassword;
        }
      }
      return false;
    } catch (e) {
      print('Error verifying password: $e');
      return false;
    }
  }

  // Update/Change existing password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // First verify the old password
      final isOldPasswordValid = await verifyPassword(oldPassword);
      if (!isOldPasswordValid) {
        throw Exception('Current password is incorrect');
      }

      // Hash the new password
      final hashedNewPassword = _hashPassword(newPassword);

      // Update the password in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'password': hashedNewPassword,
        'passwordSetAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
}