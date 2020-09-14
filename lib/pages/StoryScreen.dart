import 'package:buddiesgram/models/story.dart';
import 'package:buddiesgram/widgets/stor_userinfoWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StoryScreen extends StatefulWidget {
  final List<Story> stories;

  const StoryScreen({@required this.stories});

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> with SingleTickerProviderStateMixin{

  PageController _pageController;
  VideoPlayerController _videoPlayerController;
  AnimationController _animationController;
  int currentIndex=0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController=PageController();
    _animationController=AnimationController(vsync: this);

    _videoPlayerController=VideoPlayerController.network(widget.stories[2].url)
    ..initialize().then((value) => setState((){}));
    _videoPlayerController.play();

    final Story firstStory = widget.stories.first;
    _loadStory(story: firstStory, animateToPage: false);

    _animationController.addStatusListener((status) {
      if(status == AnimationStatus.completed){
        _animationController.stop();
        _animationController.reset();
        setState(() {
          if(currentIndex+1 < widget.stories.length){
            currentIndex+=1;
            _loadStory(story: widget.stories[currentIndex]);
          }
          else{
            //out of bound - loop story
            currentIndex=0;
            _loadStory(story: widget.stories[currentIndex]);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _pageController.dispose();
    _animationController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Story story = widget.stories[currentIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) => _onTapDown(details,story),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder:(context,i){
                final Story story=widget.stories[i];
                switch(story.media){
                  case MediaType.image:
                    return CachedNetworkImage(
                        imageUrl: story.url,
                      fit: BoxFit.cover,
                    );
                  case MediaType.video:
                    if(_videoPlayerController!=null && _videoPlayerController.value.initialized){
                      return FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoPlayerController.value.size.width,
                          height: _videoPlayerController.value.size.height,
                          child: VideoPlayer(_videoPlayerController),
                        ),
                      );
                    }
                }
                return const SizedBox.shrink();
                }
            ),
            Positioned(
              top: 40,
                left: 10,
                right: 10,
                child: Column(
                  children: [
                    Row(
                      children: widget.stories
                          .asMap()
                          .map((key, value) {
                            return MapEntry(
                                key,
                                AnimatedBar(
                                  animationController:_animationController,
                                  position:key,
                                  currentIndex: currentIndex,
                                ),
                        );
                      })
                          .values
                          .toList(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:1.5, vertical: 10),
                      child: UserInfo(user: story.user),
                    ),
                  ],
                ),
            )
          ],
        ),
      ),
    );
  }

  void _onTapDown(TapDownDetails details,Story story){
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    if(dx < screenWidth/3){
      //left screen tapped
      setState(() {
        if(currentIndex-1>=0){
          currentIndex-=1;
          _loadStory(story: widget.stories[currentIndex]);
        }
      });
    }
    else if(dx>2*screenWidth/3){
      //right screen tapped
      setState(() {
        if(currentIndex+1<widget.stories.length){
          currentIndex+=1;
          _loadStory(story: widget.stories[currentIndex]);
        }
        else{
          //out of bound
          currentIndex=0;
          _loadStory(story: widget.stories[currentIndex]);
        }
      });
    }
    else{
      //middle of screen tapped
      if(story.media==MediaType.video){
        if(_videoPlayerController.value.isPlaying){
          _videoPlayerController.pause();
          _animationController.stop();
        }
        else{
          _videoPlayerController.play();
          _animationController.forward();
        }
      }
    }
  }

  void _loadStory({Story story, bool animateToPage = true}){
    _animationController.stop();
    _animationController.reset();
    switch (story.media){
      case MediaType.image:
        _animationController.duration=story.duration;
        _animationController.forward();
        break;
      case MediaType.video:
        _videoPlayerController=null;
        _videoPlayerController?.dispose();
        _videoPlayerController = VideoPlayerController.network(story.url)
         ..initialize().then((_){
           setState(() {});
           if(_videoPlayerController.value.initialized){
             _animationController.duration = _videoPlayerController.value.duration;
             _videoPlayerController.play();
             _animationController.forward();
           }
         });
        break;
    }
    if(animateToPage){
      _pageController.animateToPage(
          currentIndex,
          duration: const Duration(milliseconds: 1),
          curve: Curves.easeInOut,
      );
    }
  }
}

class AnimatedBar extends StatelessWidget {
  final AnimationController animationController;
  final int position;
  final int currentIndex;

  const AnimatedBar({
    Key key,
    @required this.animationController,
    this.position,
    this.currentIndex,
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: LayoutBuilder(
            builder: (context,constraints){
              return Stack(
                children: [
                  _buildContainer(
                    double.infinity,
                    position<currentIndex
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                  ),
                  position==currentIndex
                  ? AnimatedBuilder(
                      animation: animationController,
                      builder: (context,child){
                        return _buildContainer(
                          constraints.maxWidth * animationController.value,
                          Colors.white,
                        );
                      },
                  )
                      : const SizedBox.shrink(),
                ],
              );
            }
        ),
      ),
    );
  }

  Container _buildContainer(double width, Color color){
    return Container(
      height: 5,
      width: width,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.black26,
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(3.0),
      ),
    );
  }
}

