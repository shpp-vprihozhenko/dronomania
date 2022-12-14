/*
- строгая / нестрогая готовка - только то, что в списке или рандом
- нарезка - почти всё.
- ресайз - без выделения?
- полить майнезом, кетчупом
- посолить
- название и иконка
 */
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String nodeEndPoint = 'http://173.212.250.234:6641';
Size glScreenSize = Size(0,0);
Size glCartSize = Size(250, 150);
double glCartX1 = 0,  glCartX2 = 0;
double ingredientInCartWidth = 50;
List <Ingredient> glCartIngredients = [];
List <Ingredient> glFinalIngredients = [];
Product glProductToMake = Product('');
Size knifeSize = Size(163,150);
final double cutSize = 90;
const kpi = 3.1415926/180;

printD(text){
  if (kDebugMode) {
    print(text);
  }
}

Future <void> showAlertPage(context, String msg) async {
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(msg),
        );
      }
  );
}

Future <void> showResultPage(context, String msg1, String msg2, bool isWin) async {
  Size size = MediaQuery.of(context).size;
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            width: size.width*0.75, height: 200,
            color: Colors.green.withOpacity(0.5),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(msg1,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                      color: isWin? Colors.purple:Colors.red),
                  ),
                  const SizedBox(height: 12,),
                  msg2==''? const SizedBox() : Text(msg2, style: const TextStyle(fontSize: 24), textAlign: TextAlign.center,),
                  const SizedBox(height: 12,),
                  ElevatedButton(onPressed: (){
                    Navigator.pop(context);
                  }, child: const Text('OK'))
                ],
              )
            )
          ),
        );
      }
  );
}

class Ingredient {
  String name = '', img = '';
  int state = 0;
  String cutPieceName = '';
  int cutQuantity = 1;

  Ingredient(this.name, this.img, [this.cutPieceName='', this.cutQuantity=5]);

  @override
  String toString() {
    return 'Product $name ingredientsForProduct $img';
  }
}

List <Ingredient> cut_ingredients = [
  Ingredient('Кусочек колбасы', 'кус_колб.png'),
  Ingredient('Кусочек помидора', 'pomidor_kol.png'),
];

List <Ingredient> ingredients = [
  Ingredient('Капуста',   'kapusta.png'),
  Ingredient('Морковка',  'morkovka.png'),
  Ingredient('Буряк',     'burak.png'),
  Ingredient('Сосиска',   'sosiska.png'),
  Ingredient('Колбаса',   'колб2.png', 'Кусочек колбасы', 4),
  Ingredient('Сыр',       'syr.webp'),
  Ingredient('Картошка',  'kartoshka.webp'),
  Ingredient('Тесто',     'testo.png'),
  Ingredient('Кастрюля',  'кастрюля.webp'),
  Ingredient('Ложка',     'Ложка.webp'),
  Ingredient('Лук',       'Лук.png'),
  Ingredient('Чеснок',    'Чеснок.webp'),
  Ingredient('Помидор',   'помидор1.png', 'Кусочек помидора', 3),
  Ingredient('Соль',      'Соль.png'),
  Ingredient('Сахар',     'Сахар.png'),
  Ingredient('Майонез',   'Майонез.webp'),
  Ingredient('Кетчуп',    'Кетчуп4.webp'),
  Ingredient('Вода',      'Вода.webp'),
  Ingredient('Масло',     'масло.webp'),
  Ingredient('Яблоко',    'Яблоко.webp'),
  Ingredient('Груша',     'Груша.webp'),
  Ingredient('Виноград',  'Виноград.webp'),
  Ingredient('Апельсин',  'Апельсин.webp'),
  Ingredient('Банан',     'Банан.webp'),
  Ingredient('Мука',      'Мука.webp'),
  Ingredient('Мяч',       'Мяч.png'),
  Ingredient('Собачка',   'Собачка.png'),
  Ingredient('Кубик',     'Кубик.png'),
  Ingredient('Кукла',     'Кукла.webp'),
  Ingredient('Сумка',     'Сумка.png'),
  Ingredient('Кошелёк',   'Кошелёк.webp'),
  Ingredient('Бананка',   'Бананка.png'),
  Ingredient('Грузовик',  'Грузовик.webp'),
  Ingredient('Машинка',   'Машинка.webp'),
  Ingredient('Фен',       'Фен.webp'),
  Ingredient('Помада',    'Помада.png'),
  Ingredient('Чайник',    'Чайник.gif'),
];

class IngredientOnMap {
  int layerNumber = 0;
  Ingredient ingredient;
  Offset position = const Offset(0, 0);
  Size size = Size(80, 80);
  bool isDragging = false, isEnabled = true, isResizeMode = false;
  Widget? widget;
  int state = 0, idx = -1, cutQuantity = 0;

  IngredientOnMap(this.ingredient, this.position, {this.cutQuantity=0});

  @override
  String toString() {
    return 'Ingredient $ingredient at $position';
  }
}

class IngredientsForProduct {
  Ingredient ingredient;
  int quantity;

  IngredientsForProduct(this.ingredient, this.quantity);

  @override
  String toString() {
    return 'IngredientForProduct $ingredient quantity $quantity';
  }
}

class Product {
  String name = '';
  List <IngredientsForProduct> ingredientsForProduct = [];
  String img = '';

  Product(this.name);

  @override
  String toString() {
    return 'Product $name ingredientsForProduct $ingredientsForProduct img $img';
  }
}

List <Product> products = [];

Ingredient glGetIngredientByName(name) {
  return ingredients.firstWhere((element) => element.name == name);
}

/*
glSaveMRL() async {
  var mrvl = [];
  missionResultList.forEach((mr) {
    var mrv = {};
    mrv["missionName"] = mr.missionName;
    mrv["missionIdx"] = mr.missionIdx;
    mrv["bestTime"] = mr.bestTime;
    mrvl.add(mrv);
  });
  String mrs = jsonEncode(mrvl);
  printD('missionResultList encoded to $mrs');
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('missionResultList', mrs);
  printD('missionResultList saved');
}

Future <void> glRestoreMRL() async {
  final prefs = await SharedPreferences.getInstance();
  String? s = prefs.getString('missionResultList');
  if (s == null) {
    printD('no saved data');
    return;
  }
  var mrvl = jsonDecode(s);
  printD('mrvl $mrvl');

  missionResultList = [];
  mrvl.forEach((mrv){
    MissionResult mr = MissionResult();
    mr.missionName = mrv["missionName"];
    mr.missionIdx = mrv["missionIdx"];
    mr.bestTime = mrv["bestTime"];
    missionResultList.add(mr);
  });
  printD('missionResultList restored $missionResultList');
}

 */

glShowRequiredIngredients(context, Product product) async {
  Size size = MediaQuery.of(context).size;
  double width = size.width*0.8;
  double height = size.height*0.7;
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            width: width, height: height,
            child: Column(
              children: [
                Text('На ${product.name}', textScaleFactor: 1.5,),
                SizedBox(height: 8,),
                Text('тебе понадобятся:', textScaleFactor: 1.5,),
                SizedBox(height: 16,),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent),
                    ),
                    child: ListView.builder(
                        itemCount: product.ingredientsForProduct.length,
                        itemBuilder: (context, idx){
                          IngredientsForProduct ifp = product.ingredientsForProduct[idx];
                          List <Widget> il = [];
                          for (int j=0; j<ifp.quantity; j++) {
                            il.add(Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset('assets/images/'+ifp.ingredient.img, height: 60, width: 60,),
                            ));
                          }
                          return Container(
                            color: idx%2==0? Colors.grey[200]:Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  ClipOval(
                                    child: Container(
                                      padding: const EdgeInsets.all(10.0),
                                      color: Colors.lightBlueAccent[100],
                                      child: Text(ifp.ingredient.name, textScaleFactor: 1.5,),
                                    ),
                                  ),
                                  SizedBox(width: 30,),
                                  ...il
                                ],
                              ),
                            ),
                          );
                        }
                    ),
                  ),
                ),
                SizedBox(height: 16,),
                ElevatedButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text('OK')
                ),
              ],
            ),
          ),
        );
      }
  );
}

void showIngredient(context, Ingredient ingredient) {
  //speak(ingredient.name);
  if (ingredient.img == '') {
    return;
  }
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(ingredient.name, textScaleFactor: 2, textAlign: TextAlign.center,),
              SizedBox(height: 15,),
              Image.asset('assets/images/${ingredient.img}'),
            ],
          ),
        );
      }
  );
}
