enum NoYes {
  YES,
  NO,
}

extension YesNoExtension on NoYes {
  String get id {
    switch (this) {
      case NoYes.YES:
        return 'Y';
      case NoYes.NO:
        return 'N';
    }
  }

  String get name {
    switch (this) {
      case NoYes.YES:
        return 'Yes';
      case NoYes.NO:
        return 'No';
    }
  }
}