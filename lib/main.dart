import 'package:dronomania/about.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'globals.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'make_gamburger.dart';
import 'select_product.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ukrainian drone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PovarStartPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PovarStartPage extends StatefulWidget {
  const PovarStartPage({Key? key}) : super(key: key);

  @override
  State<PovarStartPage> createState() => _PovarStartPageState();
}

class _PovarStartPageState extends State<PovarStartPage> {

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  _u24() async {
    await launchUrl(Uri.parse('https://u24.gov.ua/dronation'));
    printD('+');
    setState(() {});
  }

  _startMakeHamburger(){
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SelectProduct())
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    PreferredSizeWidget appBarW = AppBar(title: Row(
        children: [
          Image.asset('assets/ukraine.png', width: 40,),
          const SizedBox(width: 12,),
          const Text('Повар'),
          const Spacer(),
          IconButton(
            onPressed: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const About())
              );
            },
            icon: const Icon(Icons.help, size: 24,),
          ),
        ]),);
    glScreenSize = Size(size.width, size.height - appBarW.preferredSize.height - MediaQuery.of(context).padding.top);
    printD('screen size $size');
    return Scaffold(
      appBar: appBarW,
      body: Container(
        width: double.infinity, height: double.infinity,
        // decoration: const BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage("assets/bg2.jpg"),
        //     fit: BoxFit.cover,
        //   ),
        // ),
        child: Center(
          child: ElevatedButton(onPressed: _startMakeHamburger, child: Text('Make Gamburger')),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AvatarGlow(
            endRadius: 80,
            child: SizedBox(
              width: 100, height: 100,
              child: FloatingActionButton(
                backgroundColor: Colors.blue.withOpacity(0.1),
                onPressed: _u24,
                child: ClipOval(
                  child: Image.asset('assets/u24.jpg', width: 100, height: 100,),
                ),
              ),
            ),
          ),
          // Row(
          //   mainAxisSize: MainAxisSize.min,
          //   children: [
          //     Image.asset('assets/bomb2.png', height: 35,),
          //     const SizedBox(width: 10,),
          //     Text('$glExtraSpeedBombsQuantity', style: const TextStyle(
          //         fontSize: 24,
          //         color: Colors.yellow
          //     ),),
          //   ],
          // ),
        ],
      ),
    );
  }
}

