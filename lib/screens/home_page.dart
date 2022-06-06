import 'package:ALPHA_RADIO/model/radio.dart';
import 'package:alan_voice/alan_voice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';
import '../utils/ai_util.dart';
import 'package:audioplayers/audioplayers.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          child: Container(              
          color: AIColors.primaryColor1,
            child: radiosInitialised
                ? [
                  100.heightBox,
                  "All Channels".text.semiBold.xl.white.make().px16(),
                  20.heightBox,
                  ListView(
                    padding: Vx.m0,
                    shrinkWrap: true,
                    children: radios.map((e)=>ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(e.icon),
                      ),
                        title: "${e.name} FM".text.white.make(),
                      subtitle: e.tagline.text.white.make(),
                    )).toList()
                  ).expand()
                ].vStack(
              crossAlignment: CrossAxisAlignment.start
               )
                : const Offstage(),
          )
        ),
        body: Stack(
          children: [
            VxAnimatedBox()
                .size(context.screenWidth, context.screenHeight)
                .withGradient( const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 0, 201, 200),
                    Color.fromARGB(255, 0, 0, 0)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ))
                .make(),
              [
              AppBar(
              title: "Alpha Radio".text.xl4.bold.white.make().shimmer(
                  primaryColor: Vx.blue300, secondaryColor: Colors.white),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              centerTitle: true,
            ).h(100.0).p16(),
            20.heightBox,
            "Start with Hey Alan 😉".text.semiBold.black.make(),
            10.heightBox,
            VxSwiper.builder(
            itemCount: sugg.length,
            height: 50,
            viewportFraction: 0.35,
            autoPlay: true,
            autoPlayAnimationDuration: 3.seconds,
            autoPlayCurve: Curves.linear,
            enableInfiniteScroll: true,
            itemBuilder: (context, index){
              final s = sugg[index];
              return Chip(
                label: s.text.make(),
                backgroundColor: Vx.randomColor,
              );
            },
            )
            ].vStack(
            alignment: MainAxisAlignment.start
          ),
            30.heightBox,
            radiosInitialised
                ? VxSwiper.builder(
                    itemCount: radios.length,
                    aspectRatio: 1.0,
                    itemBuilder: (context, index) {
                      final rad = radios[index];
                      return VxBox(
                              child: ZStack(
                        [
                          Positioned(
                              top: 0.0,
                              right: 0.0,
                              child: VxBox(
                                      child: rad.category.text.uppercase.white
                                          .make()
                                          .p12())
                                  .height(40)
                                  .black
                                  .alignCenter
                                  .bottomLeftRounded(value: 10)
                                  .make()),
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: VStack([
                                rad.name.text.xl3.white.bold.makeCentered(),
                                5.heightBox,
                                rad.tagline.text.sm.white.semiBold
                                    .makeCentered(),
                              ])),
                          Align(
                              alignment: Alignment.center,
                              child: [
                                const Icon(Icons.play_circle,
                                    color: Colors.white),
                                10.heightBox,
                                "Double tap to Play".text.gray300.make()
                              ].vStack())
                        ],
                      ))
                          .clip(Clip.antiAlias)
                          .bgImage(DecorationImage(
                              image: NetworkImage(rad.image),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.3),
                                  BlendMode.darken)))
                          .border(color: Colors.black, width: 5.0)
                          .withRounded(value: 60.0)
                          .make()
                          .onInkDoubleTap(() {
                        _playMusic(rad.url);
                      }).p16();
                    }).centered()
                : const Center(
                    child: CircularProgressIndicator(
                        backgroundColor: Colors.white)),
            Align(
              alignment: Alignment.bottomCenter,
              child: [
                if (_isPlaying)
                  "Playing Now - ${_selectedRadio.name} FM".text.white.makeCentered(),
                Icon(
                  _isPlaying ? Icons.pause_circle_filled_outlined : Icons.play_circle,
                  color: Colors.white,
                  size: 50.0,
                ).onInkTap(() {
                  if (_isPlaying) {
                    _audioPlayer.stop();
                  } else {
                    _playMusic(_selectedRadio.url);
                  }
                })
              ].vStack(),
            ).pOnly(bottom: context.percentHeight * 12)
          ],
          fit: StackFit.expand,
        ));
  }
}
import 'package:ALPHA_RADIO/model/radio.dart';
import 'package:alan_voice/alan_voice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';
import '../utils/ai_util.dart';
import 'package:audioplayers/audioplayers.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<MyRadio> radios;
  bool radiosInitialised = false;
  late MyRadio _selectedRadio;
  bool _isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final sugg = [
    "Play",
    "Stop",
    "Play rock music",
    "Play 107 FM",
    "Play next",
    "Play 104 FM",
    "pause",
    "Play previous",
    "Play pop music"
  ];

  @override
  void initState() {
    super.initState();
    fetchRadios();
    setUpAlan();
    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.PLAYING) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      setState(() {});
    });
  }

  fetchRadios() async {
    final radioJson = await rootBundle.loadString('assets/radio.json');
    radios = MyRadioList.fromJson(radioJson).radios;
    _selectedRadio = radios[0];
    setState(() {
      radiosInitialised = true;
    });
  }

  _playMusic(String url) {
    _audioPlayer.play(url);
    _selectedRadio = radios.firstWhere((element) => element.url == url);
    setState(() {});
  }

  setUpAlan() {
    AlanVoice.addButton(
        "Enter Your own api key",
        buttonAlign: AlanVoice.BUTTON_ALIGN_LEFT);
    AlanVoice.callbacks.add((command) => _handleCommand(command.data));
  }

  _handleCommand(Map<String, dynamic> response){
    switch(response['command']){
      case 'play': _playMusic(_selectedRadio.url);
        break;
      case 'play_channel':
        { 
          final id = response['id'];
          _audioPlayer.pause();
          MyRadio newRadio = radios.firstWhere((element) => element.id == id);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
          _playMusic(newRadio.url);
        }
        break;
      case 'stop': _audioPlayer.stop();
        break;
      case 'next': {
        final index = _selectedRadio.id;
        MyRadio newRadio;
        if(index+1>radios.length){
          newRadio = radios.firstWhere((element)=> element.id == 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        }else{
          newRadio = radios.firstWhere((element)=> element.id == index+1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        }
        _playMusic(newRadio.url);
      }
      break;
      case 'prev': {
        final index = _selectedRadio.id;
        MyRadio newRadio;
        if(index - 1 <= 0){
          newRadio = radios.firstWhere((element)=> element.id == 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        }else{
          newRadio = radios.firstWhere((element)=> element.id == index-1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        }
        _playMusic(newRadio.url);
      }
      break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          child: Container(              
          color: AIColors.primaryColor1,
            child: radiosInitialised
                ? [
                  100.heightBox,
                  "All Channels".text.semiBold.xl.white.make().px16(),
                  20.heightBox,
                  ListView(
                    padding: Vx.m0,
                    shrinkWrap: true,
                    children: radios.map((e)=>ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(e.icon),
                      ),
                        title: "${e.name} FM".text.white.make(),
                      subtitle: e.tagline.text.white.make(),
                    )).toList()
                  ).expand()
                ].vStack(
              crossAlignment: CrossAxisAlignment.start
               )
                : const Offstage(),
          )
        ),
        body: Stack(
          children: [
            VxAnimatedBox()
                .size(context.screenWidth, context.screenHeight)
                .withGradient( const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 0, 201, 200),
                    Color.fromARGB(255, 0, 0, 0)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ))
                .make(),
              [
              AppBar(
              title: "Alpha Radio".text.xl4.bold.white.make().shimmer(
                  primaryColor: Vx.blue300, secondaryColor: Colors.white),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              centerTitle: true,
            ).h(100.0).p16(),
            20.heightBox,
            "Start with Hey Alan 😉".text.semiBold.black.make(),
            10.heightBox,
            VxSwiper.builder(
            itemCount: sugg.length,
            height: 50,
            viewportFraction: 0.35,
            autoPlay: true,
            autoPlayAnimationDuration: 3.seconds,
            autoPlayCurve: Curves.linear,
            enableInfiniteScroll: true,
            itemBuilder: (context, index){
              final s = sugg[index];
              return Chip(
                label: s.text.make(),
                backgroundColor: Vx.randomColor,
              );
            },
            )
            ].vStack(
            alignment: MainAxisAlignment.start
          ),
            30.heightBox,
            radiosInitialised
                ? VxSwiper.builder(
                    itemCount: radios.length,
                    aspectRatio: 1.0,
                    itemBuilder: (context, index) {
                      final rad = radios[index];
                      return VxBox(
                              child: ZStack(
                        [
                          Positioned(
                              top: 0.0,
                              right: 0.0,
                              child: VxBox(
                                      child: rad.category.text.uppercase.white
                                          .make()
                                          .p12())
                                  .height(40)
                                  .black
                                  .alignCenter
                                  .bottomLeftRounded(value: 10)
                                  .make()),
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: VStack([
                                rad.name.text.xl3.white.bold.makeCentered(),
                                5.heightBox,
                                rad.tagline.text.sm.white.semiBold
                                    .makeCentered(),
                              ])),
                          Align(
                              alignment: Alignment.center,
                              child: [
                                const Icon(Icons.play_circle,
                                    color: Colors.white),
                                10.heightBox,
                                "Double tap to Play".text.gray300.make()
                              ].vStack())
                        ],
                      ))
                          .clip(Clip.antiAlias)
                          .bgImage(DecorationImage(
                              image: NetworkImage(rad.image),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.3),
                                  BlendMode.darken)))
                          .border(color: Colors.black, width: 5.0)
                          .withRounded(value: 60.0)
                          .make()
                          .onInkDoubleTap(() {
                        _playMusic(rad.url);
                      }).p16();
                    }).centered()
                : const Center(
                    child: CircularProgressIndicator(
                        backgroundColor: Colors.white)),
            Align(
              alignment: Alignment.bottomCenter,
              child: [
                if (_isPlaying)
                  "Playing Now - ${_selectedRadio.name} FM".text.white.makeCentered(),
                Icon(
                  _isPlaying ? Icons.pause_circle_filled_outlined : Icons.play_circle,
                  color: Colors.white,
                  size: 50.0,
                ).onInkTap(() {
                  if (_isPlaying) {
                    _audioPlayer.stop();
                  } else {
                    _playMusic(_selectedRadio.url);
                  }
                })
              ].vStack(),
            ).pOnly(bottom: context.percentHeight * 12)
          ],
          fit: StackFit.expand,
        ));
  }
}
