// app/home/currency_converter_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <--- Tambahkan import ini

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

  // Simulasi nilai tukar (dalam aplikasi nyata, ini dari API)
  final Map<String, double> _exchangeRates = {
    'IDR': 1.0,      // Basis
    'USD': 15800.0,  // 1 USD = 15800 IDR
    'EUR': 17000.0,  // 1 EUR = 17000 IDR
    'JPY': 100.0,    // 1 JPY = 100 IDR (approx. 15800/100 = 158 JPY per USD)
    'SGD': 11700.0,  // 1 SGD = 11700 IDR
  };

  void _convertCurrency() {
    setState(() {
      _resultText = ''; // Bersihkan hasil sebelumnya
      if (_amountController.text.isEmpty) {
        _resultText = 'Masukkan jumlah yang akan dikonversi';
        _convertedAmount = 0.0;
        return;
      }

      // Gunakan NumberFormat untuk parsing yang lebih fleksibel jika input pengguna
      // mungkin menggunakan koma sebagai desimal (misal: "1.000,50")
      final NumberFormat _formatter = NumberFormat.currency(
        locale: 'id_ID', // Sesuaikan dengan locale pengguna
        symbol: '', // Jangan tampilkan simbol mata uang saat parsing
        decimalDigits: null, // Biarkan NumberFormat menentukan desimal saat parsing
      );

      double? amount;
      try {
        // Coba parse dengan locale yang ditentukan
        amount = _formatter.parse(_amountController.text).toDouble();
      } catch (e) {
        // Fallback ke double.tryParse jika NumberFormat gagal (misal: input hanya "123.45")
        amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
      }

      if (amount == null || amount <= 0) {
        _resultText = 'Jumlah tidak valid atau format salah. Gunakan angka dan desimal.';
        _convertedAmount = 0.0;
        return;
      }

      // Konversi jumlah ke basis (IDR)
      final double amountInIDR = amount * _exchangeRates[_selectedFromCurrency]!;

      // Konversi dari basis (IDR) ke mata uang tujuan
      _convertedAmount = amountInIDR / _exchangeRates[_selectedToCurrency]!;

      // Format hasil dengan NumberFormat untuk tampilan yang lebih baik (misal: 100.000,50)
      final String formattedAmount = NumberFormat.currency(
        locale: 'id_ID', // Sesuaikan dengan locale pengguna (misal: 'en_US' untuk koma sebagai desimal)
        symbol: '',
        decimalDigits: 2, // Biasanya 2 desimal untuk mata uang, sesuaikan jika perlu
      ).format(amount);

      final String formattedConvertedAmount = NumberFormat.currency(
        locale: 'id_ID',
        symbol: '',
        decimalDigits: 2,
      ).format(_convertedAmount);

      _resultText =
          '$formattedAmount $_selectedFromCurrency = $formattedConvertedAmount $_selectedToCurrency';
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
      appBar: AppBar(
        title: const Text('Konverter Mata Uang'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _amountController,
              // Gunakan numberWithOptions untuk keyboard yang lebih spesifik
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false), // signed: false untuk memastikan angka positif
              decoration: InputDecoration(
                labelText: 'Jumlah',
                hintText: 'Masukkan jumlah yang akan dikonversi (misal: 1000000.50 atau 1.000.000,50)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.monetization_on),
              ),
            ),
            const SizedBox(height: 20),
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
                      ),
                    ),
                    items: _exchangeRates.keys.map((String currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFromCurrency = newValue!;
                        _resultText = ''; // Reset hasil saat pilihan berubah
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedToCurrency,
                    decoration: InputDecoration(
                      labelText: 'Ke',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _exchangeRates.keys.map((String currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedToCurrency = newValue!;
                        _resultText = ''; // Reset hasil saat pilihan berubah
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _convertCurrency,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Konversi',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              _resultText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _resultText.startsWith('Jumlah tidak valid')
                    ? Colors.red
                    : Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}