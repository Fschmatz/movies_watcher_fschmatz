enum NoYes {
  YES,
  NO,
}


extension NoYesExtension on NoYes {
  NoYes toNoYes(String input) {
    switch (input.toUpperCase()) {
      case 'YES':
      case 'Y':
        return NoYes.YES;
      case 'NO':
      case 'N':
        return NoYes.NO;
      default:
        throw ArgumentError('Invalid enum: $input');
    }
  }

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
