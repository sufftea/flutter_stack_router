class RouteValue {
  const RouteValue();

  Object get key => runtimeType;

  @override
  int get hashCode => key.hashCode;

  @override
  bool operator ==(Object other) {
    return other is RouteValue && other.key == key;
  }
}
