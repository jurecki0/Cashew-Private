import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AddInvestmentPage extends StatefulWidget {
  final InvestmentType? selectedInvestmentType;

  const AddInvestmentPage({Key? key, this.selectedInvestmentType}) : super(key: key);

  @override
  _AddInvestmentPageState createState() => _AddInvestmentPageState();
}

class _AddInvestmentPageState extends State<AddInvestmentPage> {
  InvestmentType? selectedInvestmentType;
  String? selectedSpecificInvestment;
  double? investmentPrice;
  double quantity = 0.0;
  double totalAmount = 0.0;
  bool isFetchingPrice = false;

  final Map<InvestmentType, List<String>> investmentOptions = {
    InvestmentType.preciousMetals: ['Gold', 'Silver', 'Platinum'],
    InvestmentType.crypto: ['Bitcoin', 'Ethereum', 'Litecoin', 'Cardano'],
    InvestmentType.stocks: ['Apple', 'Tesla', 'Microsoft'],
  };

  @override
  void initState() {
    super.initState();
    selectedInvestmentType = widget.selectedInvestmentType;
  }

  Future<void> fetchPrice(String investment) async {
    setState(() {
      isFetchingPrice = true;
    });
    // Simulate a network call for fetching price
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      investmentPrice = 100.0; // Example static price
      isFetchingPrice = false;
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
                  totalAmount = 0.0;
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
            if (isFetchingPrice)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (investmentPrice != null && !isFetchingPrice)
              Text("price".tr() + ": \$${investmentPrice!.toStringAsFixed(2)}"),
            SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "quantity".tr()),
              onChanged: (value) {
                double? input = double.tryParse(value);
                if (input != null && input >= 0) {
                  quantity = input;
                  calculateTotal();
                } else {
                  setState(() {
                    quantity = 0.0;
                    totalAmount = 0.0;
                  });
                }
              },
            ),
            SizedBox(height: 16),
            Text("total-amount".tr() + ": \$${totalAmount.toStringAsFixed(2)}"),
            Spacer(),
            ElevatedButton(
              onPressed: (selectedSpecificInvestment != null && quantity > 0 && investmentPrice != null)
                  ? addTransaction
                  : null,
              child: Text("add-investment".tr()),
            ),
          ],
        ),
      ),
    );
  }
}

enum InvestmentType { preciousMetals, crypto, stocks }