import 'package:flutter/material.dart';
import 'package:one_context/one_context.dart';
import 'package:devinci/extra/globals.dart' as globals;

BuildContext getContext() {
  if (globals.notesPageKey.currentState != null) {
    return globals.notesPageKey.currentState.context;
  } else if (globals.mainPageKey.currentState != null) {
    return globals.mainPageKey.currentState.context;
  } else {
    return OneContext().context;
  }
}

void setState(void Function() fun, {bool condition = true}) {
  if (globals.notesPageKey.currentState != null) {
    if (globals.notesPageKey.currentState.mounted && condition) {
      // ignore: invalid_use_of_protected_member
      globals.notesPageKey.currentState.setState(fun);
    }
  }
}
