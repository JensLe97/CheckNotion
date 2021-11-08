import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html_character_entities/html_character_entities.dart';
import 'package:checknotion/controllers/quiz_controller.dart';
import 'package:checknotion/controllers/quiz_state.dart';
import 'package:checknotion/enums/Difficulty.dart';
import 'package:checknotion/models/failure_model.dart';
import 'package:checknotion/models/question_model.dart';
import 'package:checknotion/repositories/quiz_repository.dart';
//import 'package:translator/translator.dart';

// Provides a requested List of Question with certain parameters
final quizQuestionProvider = FutureProvider.autoDispose<List<Question>>(
  (ref) => ref.watch(quizRepositoryProvider).getQuestion(
        numQuestions: 5,
        categoryId: Random().nextInt(24) + 9,
        difficulty: Difficulty.any,
      ),
);

class Quiz extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final quizQuestions = useProvider(quizQuestionProvider);
    final pageController = usePageController();
    return Container(
      child: Scaffold(
          appBar: AppBar(
            title: IndexedStack(children: [
              Center(
                child: Text('Quiz'),
              ),
            ]),
          ),
          body: quizQuestions.when(
            data: (questions) => _buildBody(context, pageController, questions),
            loading: () => Center(
              child: Platform.isIOS
                  ? CupertinoActivityIndicator()
                  : CircularProgressIndicator(),
            ),
            error: (error, _) => QuizError(
                message: error is Failure
                    ? error.message
                    : 'Etwas ist schiefgelaufen...'),
          ),
          // Display a button at the bottom for the next questions
          // or the quiz results
          bottomSheet: quizQuestions.maybeWhen(
            data: (questions) {
              final quizState = useProvider(quizControllerProvider);
              if (!quizState.answered) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.all(30.0),
                height: 50.0,
                width: double.infinity,
                alignment: Alignment.center,
                child: ElevatedButton(
                    child: Text(
                      pageController.page!.toInt() + 1 < questions.length
                          ? 'Nächste Frage'
                          : 'Ergebnis ansehen',
                      style: TextStyle(fontSize: 18),
                    ),
                    onPressed: () {
                      context
                          .read(quizControllerProvider.notifier)
                          .nextQuestion(
                              questions, pageController.page!.toInt());
                      if (pageController.page!.toInt() + 1 < questions.length) {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.linear,
                        );
                      }
                    }),
              );
            },
            orElse: () => const SizedBox.shrink(),
          )),
    );
  }

  // Control of the current display
  // Whether there is an error, a running question or the quiz is over
  Widget _buildBody(
    BuildContext context,
    PageController pageController,
    List<Question> questions,
  ) {
    if (questions.isEmpty) return QuizError(message: 'Keine Fragen gefunden.');

    final quizState = useProvider(quizControllerProvider);
    return quizState.status == QuizStatus.complete
        ? QuizResults(state: quizState, questions: questions)
        : QuizQuestions(
            pageController: pageController,
            state: quizState,
            questions: questions,
          );
  }
}

// The actual multiple choice question with the answer posibilities
class QuizQuestions extends StatelessWidget {
  final PageController pageController;
  final QuizState state;
  final List<Question> questions;

  const QuizQuestions({
    Key? key,
    required this.pageController,
    required this.state,
    required this.questions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      physics: NeverScrollableScrollPhysics(),
      itemCount: questions.length,
      itemBuilder: (BuildContext context, int index) {
        final question = questions[index];
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Frage ${index + 1} von ${questions.length}',
              style: TextStyle(fontSize: 19),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 0),
              child: Text(
                HtmlCharacterEntities.decode(question.question),
                style: TextStyle(fontSize: 17),
              ),
              // Try to translate the question (Not really good translation)
              // child: FutureBuilder(
              //   future: _getTranslation(
              //       HtmlCharacterEntities.decode(question.question)),
              //   builder: (context, AsyncSnapshot<String> snapshot) {
              //     if (!snapshot.hasData) {
              //       return Text(
              //         '',
              //         style: TextStyle(fontSize: 17),
              //       );
              //     }
              //     return Text(
              //       snapshot.data!,
              //       style: TextStyle(fontSize: 17),
              //     );
              //   },
              // ),
            ),
            Divider(
              color: Colors.black12,
              height: 15.0,
              thickness: 2.0,
              indent: 30.0,
              endIndent: 30.0,
            ),
            Column(
              children: question.answers
                  .map(
                    (e) => AnswerButton(
                      answer: e,
                      isSelected: e == state.selectedAnswer,
                      isCorrect: e == question.correctAnswer,
                      isDisplayingAnswer: state.answered,
                      onTap: () => context
                          .read(quizControllerProvider.notifier)
                          .submitAnswer(question, e),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }

  // Future<String> _getTranslation(String text) async {
  //   final translator = GoogleTranslator();
  //   var translation = await translator.translate(text, from: 'en', to: 'de');
  //   return translation.text;
  // }
}

// Display results at the end of each quiz
class QuizResults extends StatelessWidget {
  final QuizState state;
  final List<Question> questions;

  const QuizResults({
    Key? key,
    required this.state,
    required this.questions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${state.correct.length} / ${questions.length}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 50),
        ),
        const Text(
          'Richtig',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 32),
        ),
        const SizedBox(
          height: 40.0,
        ),
        Container(
          margin: const EdgeInsets.all(20.0),
          height: 50.0,
          width: double.infinity,
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () {
              context.refresh(quizRepositoryProvider);
              context.read(quizControllerProvider.notifier).reset();
            },
            child: const Text(
              'Neues Quiz',
              style: TextStyle(fontSize: 18),
            ),
          ),
        )
      ],
    );
  }
}

// Displays when something went wrong
class QuizError extends StatelessWidget {
  final message;

  const QuizError({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message ?? 'Etwas ist schiefgelaufen...'),
          const SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
            onPressed: () => context.refresh(quizRepositoryProvider),
            child: const Text('Wiederholen'),
          ),
        ],
      ),
    );
  }
}

// A button displaying a multiple choice answer
// and the correct / incorrect icon
class AnswerButton extends StatelessWidget {
  final String answer;
  final bool isSelected;
  final bool isCorrect;
  final isDisplayingAnswer;
  final VoidCallback onTap;

  const AnswerButton({
    Key? key,
    required this.answer,
    required this.isSelected,
    required this.isCorrect,
    required this.isDisplayingAnswer,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 30.0,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 20.0,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 2.0,
            ),
          ],
          border: Border.all(
            color: isDisplayingAnswer
                ? isCorrect
                    ? Colors.green
                    : isSelected
                        ? Colors.red
                        : Colors.white
                : Colors.white,
            width: 4.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                HtmlCharacterEntities.decode(answer),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: isDisplayingAnswer && isCorrect
                        ? FontWeight.bold
                        : FontWeight.normal),
              ),
            ),
            if (isDisplayingAnswer)
              isCorrect
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 21,
                    )
                  : isSelected
                      ? const Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 21,
                        )
                      : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}
