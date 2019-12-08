import 'package:bbs_flutter/category.dart';
import 'package:bbs_flutter/core/infrastracture/api/api.dart';
import 'package:flutter/material.dart';
import '../../../question.dart';

class QuestionListViewModel extends ChangeNotifier {
  final title = "Flutter 掲示板";
  final newQuestionTitleController = TextEditingController();
  final newQuestionBodyController = TextEditingController();

  Api api;
  List<Question> questions = [];
  List<Category> categories = [];
  Category category;
  int totalCount;
  LoadingState loadingState = LoadingState.normal;

  void initState() async {
    _setLoadingState(LoadingState.loading);
    final questionsWithTotalCount = await api.fetchQuestions(limit: 10);
    questions = questionsWithTotalCount.questions;
    totalCount = questionsWithTotalCount.totalCount;

    categories = await api.fetchCategories();
    clearDialogState();

    _setLoadingState(LoadingState.normal);

    notifyListeners();
  }

  void clearDialogState() {
    newQuestionTitleController.clear();
    newQuestionBodyController.clear();
    category = categories.first;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    newQuestionTitleController.dispose();
    newQuestionBodyController.dispose();
  }

  void fetchQuestions() async {
    _setLoadingState(LoadingState.loading);

    final oldQuestions = questions;
    final lastQuestion = oldQuestions.last;
    final questionsWithTotalCount =
        await api.fetchQuestions(limit: 10, sinceId: lastQuestion.id);
    final newQuestions = [
      ...oldQuestions,
      ...questionsWithTotalCount.questions
    ];
    questions = newQuestions;
    totalCount = questionsWithTotalCount.totalCount;

    _setLoadingState(LoadingState.normal);

    notifyListeners();
  }

  void selectCategory(Category newCategory) {
    category = newCategory;
    notifyListeners();
  }

  Question question(int i) {
    return questions[i];
  }

  Question makeQuestion() {
    return Question(
      title: newQuestionTitleController.text,
      body: newQuestionBodyController.text,
      category: category,
    );
  }

  createQuestion(Question question) async {
    final newQuestion = await api.postQuestion(question);
    questions = [newQuestion, ...questions];
    totalCount += 1;
    notifyListeners();
  }

  void _setLoadingState(LoadingState state) {
    loadingState = state;
    notifyListeners();
  }
}

enum LoadingState { loading, normal }
