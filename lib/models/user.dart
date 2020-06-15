import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  final String id;
  final String profileName;
  final String userName;
  final String url;
  final String email;
  final String bio;

  User({
    this.id,
    this.profileName,
    this.userName,
    this.url,
    this.email,
    this.bio,
 });

  factory User.fromDocument(DocumentSnapshot doc){
    return User(
      id: doc.documentID,
      email: doc['email'],
      userName: doc['username'],
      url: doc['photoUrl'],
      profileName: doc['displayName'],
      bio: doc['bio'],
    );
  }
}