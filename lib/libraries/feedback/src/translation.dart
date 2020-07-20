abstract class FeedbackTranslation {
  String get submitButtonText;
  String get feedbackDescriptionText;
  String get navigate;
  String get draw;
}

class EnTranslation implements FeedbackTranslation {
  @override
  String get submitButtonText => 'Envoyer';

  @override
  String get feedbackDescriptionText => 'Infos supplémentaires ?';

  @override
  String get draw => 'Dessiner';

  @override
  String get navigate => 'Naviguer';
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
