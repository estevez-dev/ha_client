part of '../main.dart';

class PurchasePage extends StatefulWidget {
  PurchasePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PurchasePageState createState() => new _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {

  bool _loaded = false;
  String _error = "";
  List<ProductDetails> _products;
  List<PurchaseDetails> _purchases;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  _loadProducts() async {
    final bool available = await InAppPurchaseConnection.instance.isAvailable();
    if (!available) {
      setState(() {
        _error = "Error connecting to store";
      });
    } else {
      const Set<String> _kIds = {'one_time_support','just_few_bucks_per_year', 'app_fan_support_per_year', 'grateful_user_support_per_year'};
      final ProductDetailsResponse response = await InAppPurchaseConnection.instance.queryProductDetails(_kIds);
      if (response.notFoundIDs.isNotEmpty) {
        Logger.d("Products not found: ${response.notFoundIDs}");
      }
      _products = response.productDetails;
      _loadPreviousPurchases();
    }
  }

  _loadPreviousPurchases() async {
    final QueryPurchaseDetailsResponse response = await InAppPurchaseConnection.instance.queryPastPurchases();
    if (response.error != null) {
      setState(() {
        _error = "Error loading previous purchases";
      });
    } else {
      _purchases = response.pastPurchases;
      for (PurchaseDetails purchase in _purchases) {
        Logger.d("Previous purchase: ${purchase.status}");
      }
      if (_products.isEmpty) {
        setState(() {
          _error = "No data found in store";
        });
      } else {
        setState(() {
          _loaded = true;
        });
      }
    }
  }

  List<Widget> _buildProducts() {
    List<Widget> productWidgets = [];
    for (ProductDetails product in _products) {
      productWidgets.add(
        ProductPurchase(
          product: product,
          onBuy: (product) => _buyProduct(product),
          purchased: _purchases.any((purchase) { return purchase.productID == product.id;}),)
      );
    }
    return productWidgets;
  }

  void _buyProduct(ProductDetails product) {
    Logger.d("Starting purchase of ${product.id}");
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    InAppPurchaseConnection.instance.buyNonConsumable(purchaseParam: purchaseParam);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> body;
    if (!_loaded) {
      body = [_error.isEmpty ? PageLoadingIndicator() : PageLoadingError(errorText: _error)];
    } else {
      body = _buildProducts();
    }
    return new Scaffold(
      appBar: new AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          Navigator.pop(context);
        }),
        title: new Text(widget.title),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: body
      ),
    );
  }
  
}