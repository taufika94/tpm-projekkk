// app/home/currency_converter_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedFromCurrency = 'IDR';
  String _selectedToCurrency = 'USD';
  double _convertedAmount = 0.0;
  String _resultText = '';

  // Define your custom colors here based on the palette
  static const Color primaryDarkBlue = Color(0xFF1F3240);
  static const Color accentTeal = Color(0xFF3B7B8C);
  static const Color backgroundLightCream = Color(0xFFF2EDDC);
  static const Color accentOrange = Color(0xFFFF8C00);
  static const Color textBrown = Color(0xFF7F3E2C);

  // Simulasi nilai tukar (dalam aplikasi nyata, ini dari API)
  final Map<String, double> _exchangeRates = {
    'IDR': 1.0, // Basis
    'USD': 15800.0, // 1 USD = 15800 IDR
    'EUR': 17000.0, // 1 EUR = 17000 IDR
    'JPY': 100.0, // 1 JPY = 100 IDR (approx. 15800/100 = 158 JPY per USD)
    'SGD': 11700.0, // 1 SGD = 11700 IDR
  };

  void _convertCurrency() {
    setState(() {
      _resultText = ''; // Bersihkan hasil sebelumnya
      if (_amountController.text.isEmpty) {
        _resultText = 'Masukkan jumlah yang akan dikonversi';
        _convertedAmount = 0.0;
        return;
      }

      final NumberFormat formatter = NumberFormat.currency(
        locale: 'id_ID', // Sesuaikan dengan locale pengguna
        symbol: '', // Jangan tampilkan simbol mata uang saat parsing
        decimalDigits: null, // Biarkan NumberFormat menentukan desimal saat parsing
      );

      double? amount;
      try {
        amount = formatter.parse(_amountController.text).toDouble();
      } catch (e) {
        amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
      }

      if (amount == null || amount <= 0) {
        _resultText = 'Jumlah tidak valid atau format salah. Gunakan angka dan desimal.';
        _convertedAmount = 0.0;
        return;
      }

      final double amountInIDR = amount * _exchangeRates[_selectedFromCurrency]!;

      _convertedAmount = amountInIDR / _exchangeRates[_selectedToCurrency]!;

      final String formattedAmount = NumberFormat.currency(
        locale: 'id_ID',
        symbol: '',
        decimalDigits: 2,
      ).format(amount);

      final String formattedConvertedAmount = NumberFormat.currency(
        locale: 'id_ID',
        symbol: '',
        decimalDigits: 2,
      ).format(_convertedAmount);

      _resultText = '$formattedAmount $_selectedFromCurrency = $formattedConvertedAmount $_selectedToCurrency';
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLightCream, // Set background color
      appBar: AppBar(
        title: const Text(
          'Konverter Mata Uang',
          style: TextStyle(color: backgroundLightCream), // Title color
        ),
        backgroundColor: primaryDarkBlue, // AppBar background
        iconTheme: const IconThemeData(color: backgroundLightCream), // Back icon color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Masukkan Jumlah',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryDarkBlue,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
              decoration: InputDecoration(
                labelText: 'Jumlah',
                hintText: 'Cth: 1.000.000,50',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accentTeal), // Border color
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accentTeal),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accentOrange, width: 2), // Focused border color
                ),
                prefixIcon: Icon(Icons.monetization_on, color: accentTeal), // Icon color
                labelStyle: TextStyle(color: textBrown), // Label text color
                hintStyle: TextStyle(color: textBrown.withOpacity(0.6)), // Hint text color
              ),
              style: TextStyle(color: primaryDarkBlue, fontSize: 16), // Input text color
              cursorColor: accentOrange, // Cursor color
            ),
            const SizedBox(height: 30),
            Text(
              'Pilih Mata Uang',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryDarkBlue,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFromCurrency,
                    decoration: InputDecoration(
                      labelText: 'Dari',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accentTeal),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accentTeal),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accentOrange, width: 2),
                      ),
                      labelStyle: TextStyle(color: textBrown),
                    ),
                    dropdownColor: backgroundLightCream, // Dropdown menu background
                    style: TextStyle(color: primaryDarkBlue, fontSize: 16), // Dropdown item text color
                    iconEnabledColor: accentTeal, // Dropdown arrow color
                    items: _exchangeRates.keys.map((String currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFromCurrency = newValue!;
                        _resultText = '';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Icon(Icons.arrow_forward, color: primaryDarkBlue, size: 30), // Arrow icon color and size
                const SizedBox(width: 15),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedToCurrency,
                    decoration: InputDecoration(
                      labelText: 'Ke',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accentTeal),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accentTeal),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accentOrange, width: 2),
                      ),
                      labelStyle: TextStyle(color: textBrown),
                    ),
                    dropdownColor: backgroundLightCream,
                    style: TextStyle(color: primaryDarkBlue, fontSize: 16),
                    iconEnabledColor: accentTeal,
                    items: _exchangeRates.keys.map((String currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedToCurrency = newValue!;
                        _resultText = '';
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _convertCurrency,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Slightly more rounded button
                ),
                backgroundColor: accentOrange, // Button background color
                foregroundColor: backgroundLightCream, // Button text color
                elevation: 5, // Add a slight shadow
              ),
              child: const Text(
                'Konversi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 40),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Text(
                _resultText.isEmpty ? 'Hasil Konversi Akan Muncul Disini' : _resultText,
                key: ValueKey<String>(_resultText), // Key is important for AnimatedSwitcher
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: _resultText.isEmpty ? 18 : 26, // Smaller text for placeholder
                  fontWeight: FontWeight.bold,
                  color: _resultText.isEmpty
                      ? textBrown.withOpacity(0.6)
                      : (_resultText.startsWith('Jumlah tidak valid') ? Colors.red : primaryDarkBlue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}