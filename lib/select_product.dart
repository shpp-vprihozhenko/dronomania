import 'package:flutter/material.dart';

import 'globals.dart';
import 'make_gamburger.dart';

class SelectProduct extends StatefulWidget {
  const SelectProduct({Key? key}) : super(key: key);

  @override
  State<SelectProduct> createState() => _SelectProductState();
}

class _SelectProductState extends State<SelectProduct> {

  @override
  void initState() {
    _initProducts();
    super.initState();
  }

  _initProducts(){
    products = [];

    Product p = Product('Пицца');
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Тесто'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Колбаса'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Помидор'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Майонез'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Сыр'), 1));
    products.add(p);

    p = Product('Хотдог');
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Тесто'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Сосиска'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Майонез'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Кетчуп'), 1));
    products.add(p);

    p = Product('Яблочный пирог');
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Тесто'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Сосиска'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Майонез'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Кетчуп'), 1));
    products.add(p);

    p = Product('Суп');
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Картошка'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Сосиска'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Лук'), 1));
    p.ingredientsForProduct.add(IngredientsForProduct(glGetIngredientByName('Кастрюля'), 1));
    products.add(p);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Что будем готовить?'),),
      body: ListView.builder(
          shrinkWrap: true,
          itemCount: products.length,
          itemBuilder: (context, idx){
            return GestureDetector(
              onTap: () async {
                print('products[idx] ${products[idx].name}');
                await glShowRequiredIngredients(context, products[idx]);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MakeHamburger(product: products[idx],))
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(products[idx].name, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24),
                ),
              ),
            );
          }
      ),
    );
  }
}
