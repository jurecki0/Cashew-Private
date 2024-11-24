import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AddInvestmentPage extends StatefulWidget {
  final InvestmentType? selectedInvestmentType;

  const AddInvestmentPage({Key? key, this.selectedInvestmentType}) : super(key: key);

  @override
  _AddInvestmentPageState createState() => _AddInvestmentPageState();
}

class HorizontalBreak extends StatelessWidget {
  const HorizontalBreak(
      {this.padding = const EdgeInsetsDirectional.symmetric(vertical: 10),
      this.color,
      super.key});
  final EdgeInsetsDirectional padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: padding,
      height: 2,
      decoration: BoxDecoration(
        color: color ?? getColor(context, "dividerColor"),
        borderRadius: BorderRadiusDirectional.all(Radius.circular(15)),
      ),
    );
  }
}

class _AddInvestmentPageState extends State<AddInvestmentPage> {
  InvestmentType? selectedInvestmentType;
  String? selectedSpecificInvestment;
  double? investmentPrice;
  double quantity = 0.0;
  double totalAmount = 0.0;

  final Map<InvestmentType, List<String>> investmentOptions = {
    InvestmentType.preciousMetals: ['Gold', 'Silver', 'Platinum'],
    InvestmentType.crypto: ['Bitcoin', 'Ethereum', 'Litecoin', 'Cardano'],
    InvestmentType.stocks: ['Apple', 'Tesla', 'Microsoft'],
    // Add more types and specific investments as needed
  };

  @override
  void initState() {
    super.initState();
    selectedInvestmentType = widget.selectedInvestmentType;
  }

  void fetchPrice(String investment) {
    // Placeholder for API logic
    // Mocking price fetch for now
    setState(() {
      investmentPrice = 100.0; // Example static price
    });
  }

  void calculateTotal() {
    setState(() {
      totalAmount = (investmentPrice ?? 0.0) * quantity;
    });
  }

  void addTransaction() {
    // Logic to save the investment as a transaction
    print('Investment added: $selectedSpecificInvestment, $quantity, $totalAmount');
    Navigator.pop(context); // Close the page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("add-investment".tr())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<InvestmentType>(
              value: selectedInvestmentType,
              hint: Text("select-investment-type".tr()),
              items: InvestmentType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last.tr()),
                );
              }).toList(),
              onChanged: (type) {
                setState(() {
                  selectedInvestmentType = type;
                  selectedSpecificInvestment = null;
                  investmentPrice = null;
                });
              },
            ),
            if (selectedInvestmentType != null)
              DropdownButton<String>(
                value: selectedSpecificInvestment,
                hint: Text("select-specific-investment".tr()),
                items: investmentOptions[selectedInvestmentType]!.map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: (item) {
                  setState(() {
                    selectedSpecificInvestment = item;
                  });
                  fetchPrice(item!);
                },
              ),
            if (investmentPrice != null) Text("price".tr() + ": \$${investmentPrice!.toStringAsFixed(2)}"),
            SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "quantity".tr()),
              onChanged: (value) {
                quantity = double.tryParse(value) ?? 0.0;
                calculateTotal();
              },
            ),
            SizedBox(height: 16),
            Text("total-amount".tr() + ": \$${totalAmount.toStringAsFixed(2)}"),
            Spacer(),
            ElevatedButton(
              onPressed: addTransaction,
              child: Text("add-investment".tr()),
            ),
          ],
        ),
      ),
    );
  }
}
