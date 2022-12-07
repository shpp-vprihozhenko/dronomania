import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'globals.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:share_extend/share_extend.dart';

class Cooking extends StatefulWidget {
  const Cooking({Key? key}) : super(key: key);

  @override
  State<Cooking> createState() => _CookingState();
}

class _CookingState extends State<Cooking> {
  List <IngredientOnMap> ingredientsOnMap = [];
  int draggingIdx = -1, selectedIdx = -1;
  double ingredientsListZoneHeight = 0;
  GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    for (int idx=0; idx<glFinalIngredients.length; idx++) {
      IngredientOnMap ingredientOnMap = IngredientOnMap(glFinalIngredients[idx], Offset(0,0));
      ingredientOnMap.idx = idx;
      ingredientOnMap.size = Size(ingredientsListZoneHeight*0.8, ingredientsListZoneHeight*0.8);
      ingredientsOnMap.add(ingredientOnMap);
    }
  }

  _fillIngredientsOnMapWidgets(){
    for (int idx=0; idx<ingredientsOnMap.length; idx++) {
      if (ingredientsOnMap[idx].size.width == 0) {
        ingredientsOnMap[idx].size = Size(ingredientsListZoneHeight, ingredientsListZoneHeight);
      }
      ingredientsOnMap[idx].widget = ingredientOnMapW(ingredientsOnMap[idx]);
    }
  }

  Widget ingredientOnMapW(IngredientOnMap ingredientOnMap) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset('assets/images/${ingredientOnMap.ingredient.img}',
          height: ingredientOnMap.state == 0? ingredientsListZoneHeight*0.8 : ingredientOnMap.size.height,
          width: ingredientOnMap.state == 0? ingredientsListZoneHeight*0.8 : ingredientOnMap.size.width,
        ),
      ),
      onPanStart: (DragStartDetails details){
        printD('start $details for ${ingredientOnMap}');
        ingredientOnMap.position = details.globalPosition - Offset(0, ingredientsListZoneHeight) + Offset(-ingredientOnMap.size.width/2,-ingredientOnMap.size.height);
        ingredientOnMap.state = 1;
        ingredientOnMap.layerNumber = maxLayer()+1;
        draggingIdx = ingredientOnMap.idx;
        setState(() {});
      },
      onPanUpdate: (DragUpdateDetails details) {
        if (details.delta.dx == 0 && details.delta.dy == 0) {
          return;
        }
        printD('update for ${ingredientOnMap}');
        if (ingredientsOnMap[draggingIdx].isResizeMode) {
          ingredientsOnMap[draggingIdx].size += details.delta;
        } else {
          ingredientsOnMap[draggingIdx].position += details.delta;
        }
        setState(() {});
      },
      onPanEnd: (DragEndDetails details) {
        printD('onPanEnd $details for ${ingredientOnMap}');
        ingredientsOnMap[draggingIdx].isResizeMode = false;
        printD('position.dy ${ingredientsOnMap[draggingIdx].position.dy} ws ingredientsListZoneHeight $ingredientsListZoneHeight');
        if (ingredientsOnMap[draggingIdx].position.dy < 1) {
          printD('position.dy ${ingredientsOnMap[draggingIdx].position.dy} ws ingredientsListZoneHeight $ingredientsListZoneHeight');
          ingredientsOnMap[draggingIdx].state = 0;
          ingredientsOnMap[draggingIdx].size = Size(ingredientsListZoneHeight, ingredientsListZoneHeight);
          setState(() {});
        }
      },
      onLongPress: (){
        printD('onTap for ${ingredientOnMap}');
        showIngredient(context, ingredientOnMap.ingredient);
      },
      onTap: (){
        if (selectedIdx == ingredientOnMap.idx) {
          selectedIdx = -1;
        } else {
          selectedIdx = ingredientOnMap.idx;
        }
        printD('selectedIdx $selectedIdx');
        setState(() {});
      },
      onDoubleTap: (){
        ingredientOnMap.layerNumber = maxLayer()+1;
        setState(() {});
        printD('ingredientOnMap $ingredientOnMap layerNumber ${ingredientOnMap.layerNumber}');
      },
    );
  }

  List <Widget> ingredientsToPrepareWL(){
    List <Widget> lw = [];
    for (int idx=0; idx < ingredientsOnMap.length; idx++) {
      IngredientOnMap ingredientOnMap = ingredientsOnMap[idx];
      if (ingredientOnMap.state != 0) {
        continue;
      }
      lw.add(ingredientOnMap.widget!);
    }
    return lw;
  }

  List <Widget> pos_ingredientsWL(){
    List <Widget> lw = [];
    List <IngredientOnMap> im = [];
    for (int idx=0; idx < ingredientsOnMap.length; idx++) {
      IngredientOnMap ingredientOnMap = ingredientsOnMap[idx];
      if (!ingredientOnMap.isEnabled) {
        continue;
      }
      if (ingredientOnMap.state == 0) {
        continue;
      }
      im.add(ingredientOnMap);
    }
    im.sort((i1, i2)=>
      i1.layerNumber.compareTo(i2.layerNumber)
    );
    for (int idx=0; idx<im.length; idx++) {
      IngredientOnMap ingredientOnMap = im[idx];
      lw.add(
          Positioned(
              left: ingredientOnMap.position.dx,
              top: ingredientOnMap.position.dy,
              child: Container(
                width: ingredientOnMap.size.width,
                height: ingredientOnMap.size.height+12,
                decoration: selectedIdx == ingredientOnMap.idx?
                BoxDecoration(
                    border: Border.all(color: Colors.blueAccent, width: 5)
                )
                    :
                null
                ,
                child: Stack(
                  children: [
                    Positioned(
                        top: 0, left: 0,
                        child: ingredientOnMap.widget!
                    ),
                    selectedIdx == ingredientOnMap.idx?
                    Positioned(
                      bottom: 0, right: 0,
                      child: GestureDetector(
                        child: Icon(Icons.aspect_ratio, size: 32,),
                        onPanUpdate: (DragUpdateDetails details){
                          ingredientOnMap.size += details.delta;
                          setState(() {});
                        },
                      ),
                    )
                        :
                    SizedBox(),
                  ],
                ),
              )
          )
      );
    }
    return lw;
  }

  maxLayer(){
    int layer = 0;
    ingredientsOnMap.forEach((element) {
      if (element.layerNumber > layer) {
        layer = element.layerNumber;
      }
    });
    return layer;
  }

  _go(){
    selectedIdx = -1;
    setState(() {});
    _shareProductToMammy();
  }

  _shareProductToMammy() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      //Uint8List pngBytes = byteData!.buffer.asUint8List();
      String fileName = await _writeByteToImageFile(byteData!);
      ShareExtend.shareMultiple([fileName], "image", subject: "Приятного аппетита!");
    } catch (e) {
      print(e);
    }
  }

  Future<String> _writeByteToImageFile(ByteData byteData) async {
    Directory? dir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    File imageFile = File("${dir!.path}/povar/${DateTime.now().millisecondsSinceEpoch}.png");
    imageFile.createSync(recursive: true);
    imageFile.writeAsBytesSync(byteData.buffer.asUint8List(0));
    return imageFile.path;
  }

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget appBarW = AppBar(
      title: Row(
        children: [
          Expanded(child: Text('Готовим ${glProductToMake.name}', overflow: TextOverflow.clip,)),
          IconButton(
            onPressed: (){
              glShowRequiredIngredients(context, glProductToMake);
            }, icon: Icon(Icons.help, size: 32, color: Colors.yellow,),
          ),
        ],
      ),
    );
    Size screenSize = MediaQuery.of(context).size;
    Size size = Size(screenSize.width, screenSize.height - appBarW.preferredSize.height - MediaQuery.of(context).padding.top);
    ingredientsListZoneHeight = size.height / 4;
    _fillIngredientsOnMapWidgets();
    return Scaffold(
      appBar: appBarW,
      body: Container(
        width: size.width, height: size.height,
        child: Column(
          children: [
            Container(
              color: Colors.yellow[200],
              width: size.width, height: ingredientsListZoneHeight,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ingredientsToPrepareWL(),
              ),
            ),
            Expanded(
              child: RepaintBoundary(
                key: _globalKey,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0, left: 0,
                      child: Container(
                        color: Colors.lightBlue[200],
                        width: size.width, height: size.height-ingredientsListZoneHeight,
                      ),
                    ),
                    ...pos_ingredientsWL(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: _go,
        child: AvatarGlow(
          endRadius: 50,
          child: ClipOval(
            child: Container(
              width: 80, height: 80,
              color: Colors.blue.withOpacity(0.6),
              padding: const EdgeInsets.all(12.0),
              child: Image.asset('assets/images/goCooking.webp', width: 70, height: 70,),
            ),
          ),
        ),
      ),
    );
  }
}
