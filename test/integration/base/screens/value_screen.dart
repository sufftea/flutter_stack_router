import 'package:flutter/material.dart';
import 'package:hyper_router/srs/value/route_value.dart';

class SomeValue extends RouteValue {
  SomeValue(this.value);

  final String value;
}

class ValueScreen extends StatelessWidget {
  const ValueScreen({
    required this.value,
    super.key,
  });

  final SomeValue value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Text(value.value),
        ],
      ),
    );
  }
}
