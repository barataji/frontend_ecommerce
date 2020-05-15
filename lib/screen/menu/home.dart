import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_commerce/model/categoryProductModel.dart';
import 'package:frontend_commerce/model/productModel.dart';
import 'package:frontend_commerce/network/network.dart';
import 'package:frontend_commerce/screen/poduk/addProduct.dart';
import 'package:frontend_commerce/screen/poduk/productCart.dart';
import 'package:frontend_commerce/screen/poduk/productDetail.dart';
import 'package:frontend_commerce/screen/poduk/searchProduct.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:device_info/device_info.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

final price = NumberFormat("#,##0", 'en_US');

class _HomeState extends State<Home> {
  var loading = false;
  List<CategoryProductModel> listCategory = [];
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceID;

  getDeviceInfo() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print("Device Info :${androidInfo.id}");
    setState(() {
      deviceID = androidInfo.id;
    });
    getTotalCart();
  }

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

  var filter = false;

  List<ProductModel> list = [];
  getProduct() async {
    setState(() {
      loading = true;
    });
    list.clear();
    final response = await http.get(NetworkUrl.getProduct());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      setState(() {
        for (Map i in data) {
          list.add(ProductModel.fromJson(i));
        }
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  var loadingCart = false;
  var totalCart = "0";
  getTotalCart() async {
    setState(() {
      loadingCart = true;
    });
    final response = await http.get(NetworkUrl.getTotalCart(deviceID));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)[0];
      String total = data['total'];
      setState(() {
        loadingCart = false;
        totalCart = total;
      });
    } else {
      setState(() {
        loadingCart = false;
      });
    }
  }

  Future<void> onRefresh() async {
    getProduct();
    getProductwithCategory();
    //getTotalCart();
    setState(() {
      filter = false;
    });
  }

  int index = 0;

  //Menambahkan Favorite
  addFavorite(ProductModel model) async {
    setState(() {
      loading = true;
    });
    final response =
        await http.post(NetworkUrl.addFavoriteWithoutLogin(), body: {
      "deviceInfo": deviceID,
      "idProduct": model.id,
    });
    final data = jsonDecode(response.body);
    int value = data['value'];
    String message = data['message'];
    if (value == 1) {
      print(message);
      setState(() {
        loading = false;
      });
    } else {
      print(message);
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getProduct();
    getProductwithCategory();
    getDeviceInfo();
    //getTotalCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProductCart()));
              },
              //Total Cart
              icon: Stack(children: <Widget>[
                Icon(Icons.shopping_cart),
                totalCart == "0"
                    ? SizedBox()
                    : Positioned(
                        right: 0,
                        top: -4,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.deepPurple),
                          child: Text(
                            "$totalCart",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
              ]),
            )
          ],
          backgroundColor: Colors.deepOrange,
          title: InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SearchProduct()));
            },
            child: Container(
              height: 50,
              padding: EdgeInsets.all(4),
              child: TextField(
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                    hintText: "Search your Product",
                    fillColor: Colors.white,
                    filled: true,
                    enabled: false,
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.search,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(style: BorderStyle.none),
                    )),
              ),
            ),
          ),
        ),
        floatingActionButton: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProduct(),
                ));
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.deepOrange,
            ),
            child: Text(
              "Add Product",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
        body: loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: onRefresh,
                child: ListView(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),

                    //Kategori Produk
                    Container(
                      height: 50,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: listCategory.length,
                        itemBuilder: (context, i) {
                          final a = listCategory[i];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                filter = true;
                                index = i;
                                print(filter);
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 8, left: 8),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.blue),
                              child: Text(
                                a.categoryName,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    //Produk
                    filter
                        ? listCategory[index].product.length == 0
                            ? Container(
                                height: 100,
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "Sorry Product on This Category not available",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                padding: EdgeInsets.all(10),
                                itemCount: listCategory[index].product.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                ),
                                itemBuilder: (context, i) {
                                  final a = listCategory[index].product[i];
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductDetail(
                                                      a, getTotalCart)));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1,
                                              color: Colors.grey[300]),
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 5,
                                                color: Colors.grey[300])
                                          ]),
                                      padding: EdgeInsets.all(8),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          Expanded(
                                            child: Stack(
                                              children: <Widget>[
                                                Image.network(
                                                  "http://192.168.43.184/ecommerce/product/${a.cover}",
                                                  fit: BoxFit.cover,
                                                  height: 180,
                                                ),
                                                Positioned(
                                                  top: -10,
                                                  right: 0,
                                                  child: Container(
                                                    height: 50,
                                                    width: 40,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.rectangle,
                                                      color:
                                                          Colors.orangeAccent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: IconButton(
                                                      onPressed: () {
                                                        addFavorite(a);
                                                      },
                                                      icon: Icon(
                                                        Icons.favorite,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            "${a.productName}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            "Rp. ${price.format(a.sellingPrice)}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              color: Colors.red,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                })
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            padding: EdgeInsets.all(10),
                            itemCount: list.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                            itemBuilder: (context, i) {
                              final a = list[i];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetail(a, getTotalCart)));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.grey[300]),
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 5,
                                            color: Colors.grey[300])
                                      ]),
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Expanded(
                                        child: Stack(
                                          children: <Widget>[
                                            Image.network(
                                              "http://192.168.43.184/ecommerce/product/${a.cover}",
                                              fit: BoxFit.cover,
                                              height: 180,
                                            ),
                                            Positioned(
                                              top: -10,
                                              right: 0,
                                              child: Container(
                                                height: 50,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  color: Colors.orangeAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: IconButton(
                                                  onPressed: () {
                                                    addFavorite(a);
                                                  },
                                                  icon: Icon(
                                                    Icons.favorite,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        "${a.productName}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        "Rp. ${price.format(a.sellingPrice)}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          color: Colors.red,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ));
  }
}
