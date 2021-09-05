import 'package:little_tricks/enums/Difficulty.dart';
import 'package:little_tricks/models/question_model.dart';

// Baseclass for getting a certain API request
abstract class BaseQuizRepository {
  Future<List<Question>> getQuestion({
    required int numQuestions,
    required int categoryId,
    required Difficulty difficulty,
  });
}
