part of '../../main.dart';

class ProductPurchase extends StatelessWidget {

  final ProductDetails product;
  final onBuy;
  final purchased;

  const ProductPurchase({Key key, @required this.product, @required this.onBuy, this.purchased}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String period = "";
    Color priceColor;
    String buttonText = '';
    String buttonTextInactive = '';
    if (product.id.contains("year")) {
      period += "once a year";
      buttonText = "Subscribe";
      buttonTextInactive = "Already";
      priceColor = Colors.amber;
    } else {
      period += "";
      buttonText = "Pay";
      buttonTextInactive = "Paid";
      priceColor = Colors.deepOrangeAccent;
    }
    return Card(
        child: Padding(
          padding: EdgeInsets.all(Sizes.leftWidgetPadding),
          child: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Padding(
                    padding: EdgeInsets.only(right: Sizes.rightWidgetPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "${product.title}",
                          style: Theme.of(context).textTheme.body2,
                        ),
                        Container(height: Sizes.rowPadding,),
                        Text(
                          "${product.description}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                          softWrap: true,
                        ),
                        Container(height: Sizes.rowPadding,),
                        Text("${product.price} $period", style: Theme.of(context).textTheme.body1.copyWith(
                          color: priceColor
                        )),
                      ],
                    )
                ),
              ),
              Expanded(
                flex: 2,
                child: RaisedButton(
                  child: Text(this.purchased ? buttonTextInactive : buttonText, style: Theme.of(context).textTheme.button),
                  color: Colors.blue,
                  onPressed: this.purchased ? null : () => this.onBuy(this.product),
                ),
              )
            ],
          ),
        )
    );
  }
}
