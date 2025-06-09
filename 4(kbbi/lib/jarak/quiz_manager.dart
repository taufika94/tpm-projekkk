import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';

class QuizManager {
  final List<Map<String, dynamic>> quizLocations;
  final Function(String) showSnackBar;
  final TextEditingController quizAnswerController = TextEditingController();

  LatLng? _quizDestinationLatLng;
  double? _actualQuizDistance;
  String _quizDestinationName = '';

  QuizManager({
    required this.quizLocations,
    required this.showSnackBar,
  });

  Map<String, dynamic> startNewQuiz(Position currentPosition) {
    resetQuizState();

    final random = Random();
    final quizLocation = quizLocations[random.nextInt(quizLocations.length)];
    _quizDestinationLatLng = LatLng(quizLocation['lat'], quizLocation['lon']);
    _quizDestinationName = quizLocation['name'];

    final distanceCalculator = const Distance();
    _actualQuizDistance = distanceCalculator(
      LatLng(currentPosition.latitude, currentPosition.longitude),
      _quizDestinationLatLng!,
    ) / 1000;

    return {
      'question': 'Berapa perkiraan jarak (km) dari lokasi Anda saat ini ke $_quizDestinationName?',
      'destinationLatLng': _quizDestinationLatLng,
      'destinationName': _quizDestinationName,
    };
  }

  QuizResult submitAnswer() {
    if (quizAnswerController.text.isEmpty) {
      showSnackBar('Mohon masukkan jawaban Anda.');
      return QuizResult(isCorrect: false, userAnswer: 0, correctAnswer: 0, message: '');
    }

    final double? userAnswer = double.tryParse(quizAnswerController.text);
    if (userAnswer == null) {
      showSnackBar('Jawaban harus berupa angka.');
      return QuizResult(isCorrect: false, userAnswer: 0, correctAnswer: 0, message: '');
    }

    if (_actualQuizDistance == null) {
      showSnackBar('Terjadi kesalahan, jarak kuis tidak diketahui.');
      return QuizResult(isCorrect: false, userAnswer: 0, correctAnswer: 0, message: '');
    }

    return QuizResult.evaluateAnswer(userAnswer, _actualQuizDistance!);
  }

  void resetQuizState() {
    quizAnswerController.clear();
    _quizDestinationLatLng = null;
    _actualQuizDistance = null;
    _quizDestinationName = '';
  }

  void dispose() {
    quizAnswerController.dispose();
  }
}

class QuizResult {
  final bool isCorrect;
  final double userAnswer;
  final double correctAnswer;
  final String message;

  QuizResult({
    required this.isCorrect,
    required this.userAnswer,
    required this.correctAnswer,
    required this.message,
  });

  static QuizResult evaluateAnswer(double userAnswer, double correctAnswer) {
    final double difference = (userAnswer - correctAnswer).abs();
    String message;
    bool isCorrect;

    if (difference <= 5) {
      message = 'Hebat! Jawaban Anda sangat dekat dengan jawaban yang benar.';
      isCorrect = true;
    } else if (difference <= 20) {
      message = 'Cukup bagus! Jawaban Anda mendekati jawaban yang benar.';
      isCorrect = false;
    } else {
      message = 'Masih jauh dari jawaban yang benar. Coba lagi!';
      isCorrect = false;
    }

    return QuizResult(
      isCorrect: isCorrect,
      userAnswer: userAnswer,
      correctAnswer: correctAnswer,
      message: message,
    );
  }
}