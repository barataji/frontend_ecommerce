import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_commerce/model/categoryProductModel.dart';
import 'package:frontend_commerce/network/network.dart';
import 'package:http/http.dart' as http;

class ChooseCategoryProduct extends StatefulWidget {
  @override
  _ChooseCategoryProductState createState() => _ChooseCategoryProductState();
}

class _ChooseCategoryProductState extends State<ChooseCategoryProduct> {
  var loading = false;
  List<CategoryProductModel> listCategory = [];
  getProductwithCategory() async {
    setState(() {
      loading = true;
    });
    listCategory.clear();
    final response = await http.get(NetworkUrl.getProductCategory());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      setState(() {
        for (Map i in data) {
          listCategory.add(CategoryProductModel.fromJson(i));
        }
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getProductwithCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text("Choose Category Product"),
          elevation: 1,
        ),
        body: Container(
            padding: EdgeInsets.all(10),
            child: loading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: listCategory.length,
                    itemBuilder: (context, i) {
                      final a = listCategory[i];
                      return InkWell(
                          onTap: () {
                            Navigator.pop(context, a);
                          },
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text(a.categoryName),
                                Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Divider(
                                      color: Colors.grey,
                                    )),
                              ],
                            ),
                          ));
                    },
                  )));
  }
}
