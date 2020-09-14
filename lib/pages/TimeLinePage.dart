
import 'package:buddiesgram/models/data.dart';
import 'package:buddiesgram/pages/StoryScreen.dart';
import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashed_circle/dashed_circle.dart';
import 'package:flutter/material.dart';
import 'package:buddiesgram/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/widgets/PostWidget.dart';

class TimeLinePage extends StatefulWidget {

  final User gCurrentUser;

  TimeLinePage({this.gCurrentUser});

  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}


class _TimeLinePageState extends State<TimeLinePage> with SingleTickerProviderStateMixin{

  Animation base;
  Animation gap;
  Animation reverse;
  AnimationController animationController;
  bool viewedStory=false;
  List<PostWidget> posts;
  List<String> followingsList = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }


  retrieveTimeLine() async{
    QuerySnapshot querySnapshot = await timelineReference.document(widget.gCurrentUser.id).collection("timelinePosts").orderBy("timestamp",descending: true).getDocuments();

    List<PostWidget> allPosts = querySnapshot.documents.map((document) => PostWidget.fromDocument(document)).toList();

    setState(() {
      this.posts=allPosts;
    });
  }

  retrieveFollowings() async{
    QuerySnapshot querySnapshot = await timelineReference.document(widget.gCurrentUser.id).collection("userFollowing").getDocuments();

    setState(() {
      followingsList = querySnapshot.documents.map((document) => document.documentID).toList();
    });
  }

  createUserTimeLine(){
    if(posts==null){
      return circularProgress();
    }
    else{
      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(13.0),
            child: Column(
              children: [
                Container(
                  child: RotationTransition(
                    turns: base,
                    child: DashedCircle(
                      gapSize: gap.value,
                      color: viewedStory ? Colors.white30 : Color(0XFFED4634),
                      child: RotationTransition(
                        turns: reverse,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: GestureDetector(
                            onTap: (){
                              setState(() {
                                viewedStory=true;
                              });
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>StoryScreen(stories: stories)));
                            },
                            child: CircleAvatar(
                              radius: 25,
                              backgroundImage: CachedNetworkImageProvider(
                                user.url,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:5.0),
                  child: Text(user.username,style: TextStyle(color: viewedStory? Colors.white38:Colors.white),),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top:95.0),
            child: Divider(height: 10,thickness: 1.0,color: Colors.white12,),
          ),
          Padding(
            padding: const EdgeInsets.only(top:90.0),
            child: ListView(children: posts,),
          ),
        ],
      );
    }
  }

  @override
  void initState() {
    super.initState();
    retrieveTimeLine();
    retrieveFollowings();
    animationController=AnimationController(vsync: this,duration: Duration(seconds: 4));
    base = CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    reverse = Tween<double>(begin: 0.0, end: -1.0).animate(base);
    gap = Tween<double>(begin: 3.0, end: 0.0).animate(base)
      ..addListener(() {
        setState(() {});
      });
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, isAppTitle : true,),
      body: RefreshIndicator(child: createUserTimeLine(), onRefresh: () => retrieveTimeLine(),),
    );
  }
}
