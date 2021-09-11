import 'dart:io';

import 'package:dio/dio.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:checknotion/models/failure_model.dart';
import 'package:checknotion/models/question_model.dart';
import 'package:checknotion/enums/Difficulty.dart';
import 'package:checknotion/repositories/base_quiz_repository.dart';

// Dio: Http client for Dart
final dioProvider = Provider<Dio>((ref) => Dio());

// Provides the requested questions as a QuizRepository
final quizRepositoryProvider =
    Provider<QuizRepository>((ref) => QuizRepository(ref.read));

// Requests the Trivia API to get a number of questions from a category and
// with a difficulty
class QuizRepository extends BaseQuizRepository {
  final Reader _read;

  QuizRepository(this._read);

  @override
  Future<List<Question>> getQuestion({
    required int numQuestions,
    required int categoryId,
    required Difficulty difficulty,
  }) async {
    try {
      final queryParameters = {
        'type': 'multiple',
        'amount': numQuestions,
        'category': categoryId,
      };

      if (difficulty != Difficulty.any) {
        queryParameters.addAll(
          {'difficulty': EnumToString.convertToString(difficulty)},
        );
      }

      final response = await _read(dioProvider).get(
        'https://opentdb.com/api.php',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);
        final results = List<Map<String, dynamic>>.from(data['results'] ?? []);
        if (results.isNotEmpty) {
          return results.map((e) => Question.fromMap(e)).toList();
        }
      }
      return [];
    } on DioError catch (e) {
      print(e);
      throw Failure(message: e.response?.statusMessage);
    } on SocketException catch (e) {
      print(e);
      throw const Failure(message: 'Bitte Internetverbindung überprüfen.');
    }
  }
}
