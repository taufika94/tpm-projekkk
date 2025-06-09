// app/home/time_converter_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format waktu yang lebih baik

class TimeConverterPage extends StatefulWidget {
  const TimeConverterPage({super.key});

  @override
  State<TimeConverterPage> createState() => _TimeConverterPageState();
}

class _TimeConverterPageState extends State<TimeConverterPage> {
  // Waktu saat ini (berdasarkan waktu perangkat, biasanya WIB untuk di Klaten)
  DateTime _selectedTime = DateTime.now();

  // Zona waktu Indonesia:
  // WIB: GMT+7
  // WITA: GMT+8 (WIB + 1 jam)
  // WIT: GMT+9 (WIB + 2 jam)
  String _fromZone = 'WIB';
  String _toZone = 'WITA';

  // Hasil konversi
  String _convertedTimeResult = '';

  @override
  void initState() {
    super.initState();
    _convertTime(); // Lakukan konversi awal saat halaman dimuat
  }

  void _convertTime() {
    setState(() {
      // Dapatkan offset dari WIB
      int offsetHours = 0; // Default untuk WIB

      if (_fromZone == 'WITA') {
        offsetHours = -1; // WITA ke WIB
      } else if (_fromZone == 'WIT') {
        offsetHours = -2; // WIT ke WIB
      }

      // Konversi waktu yang dipilih ke referensi WIB
      DateTime timeInWIB = _selectedTime.add(Duration(hours: offsetHours));

      // Dapatkan offset ke zona tujuan dari WIB
      int targetOffsetHours = 0; // Default untuk WIB
      if (_toZone == 'WITA') {
        targetOffsetHours = 1; // WIB ke WITA
      } else if (_toZone == 'WIT') {
        targetOffsetHours = 2; // WIB ke WIT
      }

      // Konversi dari waktu referensi WIB ke zona waktu tujuan
      DateTime convertedTime = timeInWIB.add(Duration(hours: targetOffsetHours));

      // Format waktu untuk ditampilkan
      final DateFormat formatter = DateFormat('HH:mm:ss'); // Format Jam:Menit:Detik
      final DateFormat dateFormatter = DateFormat('dd-MM-yyyy'); // Format Tanggal

      _convertedTimeResult =
          '${formatter.format(_selectedTime)} $_fromZone (${dateFormatter.format(_selectedTime)})\n'
          'setara dengan\n'
          '${formatter.format(convertedTime)} $_toZone (${dateFormatter.format(convertedTime)})';
    });
  }

  // Fungsi untuk memilih waktu dari dialog
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = DateTime(
          _selectedTime.year,
          _selectedTime.month,
          _selectedTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        _convertTime(); // Lakukan konversi setelah waktu dipilih
      });
    }
  }

  // Fungsi untuk memilih tanggal dari dialog (penting jika konversi melewati tengah malam)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
        _convertTime(); // Lakukan konversi setelah tanggal dipilih
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konverter Waktu Indonesia'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Waktu Saat Ini (Perangkat): ${DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now())}',
                      style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Waktu yang Akan Dikonversi:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _selectDate(context),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(DateFormat('dd-MM-yyyy').format(_selectedTime)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () => _selectTime(context),
                          icon: const Icon(Icons.access_time),
                          label: Text(DateFormat('HH:mm').format(_selectedTime)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _fromZone,
                    decoration: InputDecoration(
                      labelText: 'Dari Zona Waktu',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: <String>['WIB', 'WITA', 'WIT']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _fromZone = newValue!;
                        _convertTime();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.compare_arrows, size: 30, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _toZone,
                    decoration: InputDecoration(
                      labelText: 'Ke Zona Waktu',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: <String>['WIB', 'WITA', 'WIT']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _toZone = newValue!;
                        _convertTime();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _convertTime,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Konversi Waktu',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'Hasil Konversi:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _convertedTimeResult,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}