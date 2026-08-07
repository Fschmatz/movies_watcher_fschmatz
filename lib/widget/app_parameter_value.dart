import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import '../redux/app_state.dart';
import '../redux/selectors.dart';
import '../redux/build_context_extension.dart';

class AppParameterValue extends StatelessWidget {
  final String parameterKey;

  const AppParameterValue({
    super.key,
    required this.parameterKey,
  });

  @override
  Widget build(BuildContext context) {
    final value = context.select((AppState state) => selectParameterValueByKey(state, parameterKey));
    return Text(value ?? '');
  }
}
