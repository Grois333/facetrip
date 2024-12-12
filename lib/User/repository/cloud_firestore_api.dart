import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facetrip/User/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../Place/model/place.dart';

class CloudFirestoreAPI{
  final String USERS = "users";
  final String PLACES = "places";

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;


  void updateUserData(User user) async{
    DocumentReference ref = _db.collection(USERS).doc(user.uid);
    return await ref.set({
      'uid': user.uid,
      'name': user.name,
      'email': user.email,
      'photoURL': user.photoURL,
      'myPlaces': user.myPlaces,
      'muFavoritePlaces': user.myFavoritePlaces,
      'lastSignIn': DateTime.now()
    }, SetOptions(merge: true));
  }

  Future<void> updatePlaceData(Place place) async {
    CollectionReference refPlaces = _db.collection(PLACES);

    auth.User? user= _auth.currentUser;
    if (user == null){
      return print("user is null");
    }else{
      refPlaces.add({
        'name': place.name,
        'description': place.description,
        'likes': place.likes,
        'userOwner': _db.doc("$USERS/${user.uid}"),
      }).then((dr){
        dr.get().then((snapshot){
          snapshot.id;// ID Places
          DocumentReference refUsers = _db.collection(USERS).doc(user.uid);
          refUsers.update({
            'myPlacces': FieldValue.arrayUnion([_db.doc("$PLACES/${snapshot.id}")])
          });
        });
      });
    }
  }

}