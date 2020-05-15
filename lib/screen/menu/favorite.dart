import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:frontend_commerce/model/productModel.dart';
import 'package:frontend_commerce/network/network.dart';
import 'package:frontend_commerce/screen/poduk/productDetail.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Favorite extends StatefulWidget {
  @override
  _FavoriteState createState() => _FavoriteState();
}

final price = NumberFormat("#,##0", 'en_US');

class _FavoriteState extends State<Favorite> {
  List<ProductModel> list = [];
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceID;

  getDeviceInfo() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print("Device Info :${androidInfo.id}");
    setState(() {
      deviceID = androidInfo.id;
    });
    getProduct();
  }

  var loading = false;
  var cekData = false;
  getProduct() async {
    setState(() {
      loading = true;
    });
    list.clear();
    final response =
        await http.get(NetworkUrl.getProductFavoriteWithoutLogin(deviceID));
    if (response.statusCode == 200) {
      if (response.contentLength == 2) {
        setState(() {
          loading = false;
          cekData = false;
        });
      } else {
        final data = jsonDecode(response.body);
        print(data);
        setState(() {
          for (Map i in data) {
            list.add(ProductModel.fromJson(i));
          }
          loading = false;
          cekData = true;
        });
      }
    } else {
      setState(() {
        loading = false;
        cekData = false;
      });
    }
  }

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
      getProduct();
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

  Future<void> onRefresh() async {
    getDeviceInfo();
  }

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Your Favorit Product"),
          backgroundColor: Colors.deepOrange,
        ),
        body: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            children: <Widget>[
              loading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : cekData
                      ? Container(
                          child: GridView.builder(
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
                                              ProductDetail(a, getProduct)));
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
                                                top: 0,
                                                right: 0,
                                                child: Container(
                                                  height: 50,
                                                  width: 40,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.rectangle,
                                                    color: Colors.orangeAccent,
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
                                                ))
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
                        )
                      : Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "You don't have product favorite yet",
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
            ],
          ),
        ));
  }
}
