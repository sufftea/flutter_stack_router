import 'package:flutter/widgets.dart';
import 'package:hyper_router/srs/route/value_route.dart';
import 'package:hyper_router/srs/value/route_value.dart';

class _StringRouteValue extends RouteValue {
  final String str;

  _StringRouteValue(this.str);
}

// mywebsite.com/home/settings
// mywebsite.com/home/<some_custom_value>
class StringRoute extends ValueRoute<_StringRouteValue> {
  StringRoute({
    required Widget Function(BuildContext context, String value) screenBuilder,
    super.pageBuilder,
    super.children,
  }) : super(
          screenBuilder: (context, value) => screenBuilder(context, value.str),
        );
}
