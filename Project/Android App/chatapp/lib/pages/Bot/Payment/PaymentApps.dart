import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';

class Payment_Apps extends StatefulWidget {
  final String price;
  const Payment_Apps({Key? key,required this.price});

  @override
  State<Payment_Apps> createState() => _Payment_AppsState();
}

class _Payment_AppsState extends State<Payment_Apps> {
  int? _selectedAppIndex;
  List<UpiApp>? _upiApps;
  bool _loadingApps = true;
  UpiIndia _upiIndia = UpiIndia();

  @override
  void initState() {
    super.initState();
    _loadUpiApps();
  }

  Future<void> _loadUpiApps() async {
    try {
      final List<UpiApp> apps =
      await UpiIndia().getAllUpiApps(mandatoryTransactionId: false);
      setState(() {
        _upiApps = apps;
        _loadingApps = false;
      });
    } catch (e) {
      print('Error loading UPI apps: $e');
      setState(() {
        _loadingApps = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Payment App',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              _loadingApps
                  ? Center(child: CircularProgressIndicator())
                  : _buildAppList(),
              Spacer(),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedAppIndex != null ? _onPayPressed : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('Pay', style: TextStyle(fontSize: 18)),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> initiateTransaction(UpiApp app) async {
    try {
      UpiResponse response = await _upiIndia.startTransaction(
        app: app,
        receiverUpiId: "8767831521@axl",
        receiverName: 'Hemanshu Patil',
        transactionRefId: DateTime.now().millisecondsSinceEpoch.toString(),
        transactionNote: 'ChatBuddy Transaction',
        amount: double.parse(widget.price),

      );

      print('Transaction Status: ${response.transactionId}');

      _checkTxnStatus(response.status.toString());
    } catch (e) {
      print('Error initiating transaction: $e');
    }
  }

  void _onPayPressed() {
    if (_selectedAppIndex != null) {
      UpiApp selectedApp = _upiApps![_selectedAppIndex!];
      initiateTransaction(selectedApp);
      print('Payment initiated with ${selectedApp.name}');
    }
  }

  void _checkTxnStatus(String status) {
    switch (status) {
      case UpiPaymentStatus.SUCCESS:
        print('Transaction Successful');
        break;
      case UpiPaymentStatus.SUBMITTED:
        print('Transaction Submitted');
        break;
      case UpiPaymentStatus.FAILURE:
        print('Transaction Failed');
        break;
      default:
        print('Received an Unknown transaction status');
    }
  }

  Widget _buildAppList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _upiApps!.length,
        itemBuilder: (context, index) {
          return RadioListTile<int>(
            value: index,
            groupValue: _selectedAppIndex,
            onChanged: (value) {
              setState(() {
                _selectedAppIndex = value;
              });
            },
            title: Row(
              children: [
                _upiApps![index].icon != null
                    ? Image.memory(
                  _upiApps![index].icon!,
                  width: 24,
                  height: 24,
                )
                    : Icon(Icons.error_outline), // Placeholder icon
                const SizedBox(width: 10),
                Text(_upiApps![index].name ?? ''),
              ],
            ),
            controlAffinity: ListTileControlAffinity.trailing,
            tileColor: Colors.grey[200],
            selectedTileColor: Colors.blue,
          );
        },
      ),
    );
  }
}
