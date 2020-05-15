import 'dart:convert';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:frontend_commerce/model/productModel.dart';
import 'package:frontend_commerce/network/network.dart';
import 'package:frontend_commerce/screen/menu/home.dart';
import 'package:http/http.dart' as http;

class ProductDetail extends StatefulWidget {
  final ProductModel model;
  final VoidCallback reload;
  ProductDetail(this.model, this.reload);
  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceID;

  getDeviceInfo() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print("Device Info :${androidInfo.id}");
    setState(() {
      deviceID = androidInfo.id;
    });
  }

  addCart() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Processing"),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 4,
                  ),
                  Text("Loading...")
                ],
              ),
            ),
          );
        });
    final response = await http.post(NetworkUrl.addCart(),
        body: {"unikID": deviceID, "idProduct": widget.model.id});
    final data = jsonDecode(response.body);
    int value = data['value'];
    String message = data['message'];
    if (value == 1) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Information"),
              content: Text(message),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      Navigator.pop(context);
                      widget.reload();
                    });
                  },
                  child: Text("Ok"),
                )
              ],
            );
          });
    } else {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Warning"),
              content: Text(message),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Ok"),
                )
              ],
            );
          });
    }
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
        backgroundColor: Colors.deepOrange,
        title: Text("${widget.model.productName}"),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(8),
                children: <Widget>[
                  Image.network(
                    "http://192.168.43.184/ecommerce/product/${widget.model.cover}",
                    fit: BoxFit.cover,
                    height: 180,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    "${widget.model.productName}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Divider(
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "${widget.model.description}",
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Rp. ${price.format(widget.model.sellingPrice)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  height: 60,
                  width: 90,
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.deepOrange),
                  child: IconButton(
                    onPressed: () {
                      addCart();
                    },
                    icon: Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
