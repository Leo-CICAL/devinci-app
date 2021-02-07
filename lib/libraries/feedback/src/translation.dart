import 'package:get/get.dart';

abstract class FeedbackTranslation {
  String get submitButtonText;
  String get feedbackDescriptionText;
  String get navigate;
  String get draw;
}

class EnTranslation implements FeedbackTranslation {
  @override
  String get submitButtonText => 'send'.tr;

  @override
  String get feedbackDescriptionText => 'more_info'.tr;

  @override
  String get draw => 'draw'.tr;

  @override
  String get navigate => 'navigate'.tr;
}

class DeTranslation implements FeedbackTranslation {
  @override
  String get submitButtonText => 'Abschicken';

  @override
  String get feedbackDescriptionText => 'Was können wir besser machen?';

  @override
  String get draw => 'Malen';

  @override
  String get navigate => 'Navigieren';
}
