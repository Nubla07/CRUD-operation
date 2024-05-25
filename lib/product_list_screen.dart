import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:random_1/add_product.dart';
import 'package:random_1/product_model.dart';
import 'package:random_1/update_product.dart';
import 'package:http/http.dart' as http;

class CrudPage extends StatefulWidget {
  const CrudPage({super.key});

  @override
  State<CrudPage> createState() => _CrudPageState();
}

class _CrudPageState extends State<CrudPage> {
  bool _getinprogress = false;
  List<ProductModel> productList = [];

  @override
  void initState() {
    super.initState();
    _getlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade100,
        title: const Text(
          "CRUD App",
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _getlist,
        child: Visibility(
          visible: !_getinprogress,
          replacement: const Center(
            child: CircularProgressIndicator(),
          ),
          child: ListView.separated(
            separatorBuilder: (_, __) => const Divider(),
            itemCount: productList.length,
            itemBuilder: (context, index) {
              return _buildProductItem(productList[index]);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade300,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProduct(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _getlist() async {
    setState(() {
      _getinprogress = true;
    });

    const String productListUrl =
        'https://crud.teamrabbil.com/api/v1/ReadProduct';
    Uri uri = Uri.parse(productListUrl);
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      final jsonProductList = decodedData['data'] as List;

      List<ProductModel> tempList = [];
      for (Map<String, dynamic> json in jsonProductList) {
        ProductModel productModel = ProductModel.fromjson(json);
        tempList.add(productModel);
      }
      setState(() {
        productList = tempList.cast<ProductModel>();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Get failed! Try again."),
        ),
      );
    }

    setState(() {
      _getinprogress = false;
    });
  }

  ListTile _buildProductItem(ProductModel product) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      tileColor: Colors.blue.shade200,
      leading: Image.network(
        "https://w7.pngwing.com/pngs/297/963/png-transparent-starry-night-by-vincent-van-gogh-the-starry-night-jigsaw-puzzles-van-gogh-1853-1890-van-gogh-posters-painting-starry-night-blue-computer-wallpaper-canvas-thumbnail.png",
        height: 60,
        width: 60,
      ),
      title: Text(
        product.productName ?? '',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Wrap(
        spacing: 16,
        children: [
          Text("Unit Price: ${product.unitPrice}"),
          Text("Quantity: ${product.quality}"),
          Text("Total Price: ${product.totalPrice}"),
        ],
      ),
      trailing: Wrap(
        children: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateProduct(
                    product: product,
                  ),
                ),
              );
              if (result == true) {
                _getlist();
              }
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              _showDeleteConfirmationDialog(product.id!);
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(String productId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete'),
          content: const Text('Are you sure to delete?'),
          actions: [
            TextButton.icon(
              onPressed: () {
                _deleteProduct(productId);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct(String productId) async {
    setState(() {
      _getinprogress = true;
    });

    String deleteProductUrl =
        'https://crud.teamrabbil.com/api/v1/DeleteProduct/$productId';
    Uri uri = Uri.parse(deleteProductUrl);
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      _getlist();
    } else {
      _getinprogress = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Delete Product failed! Try again."),
        ),
      );
    }
  }
}
