class UrlData {
  UrlData({
    required this.segments,
    Map<String, List<String>>? queryParams,
    Map<Object, Object?>? states,
  })  : queryParams = queryParams ?? {},
        states = states ?? {};

  final Iterable<String> segments;
  Map<String, List<String>> queryParams;
  Map<Object, Object?> states;

  UrlData copyWith(Iterable<String> segments) {
    return UrlData(
      segments: segments,
      queryParams: queryParams,
      states: states,
    );
  }

  UrlData prefixWith(UrlData url) {
    return UrlData(
      segments: url.segments.followedBy(segments),
      queryParams: {...url.queryParams, ...queryParams},
      states: {...url.states, ...states},
    );
  }

  UrlData followedBy(UrlData url) {
    return UrlData(
      segments: segments.followedBy(url.segments),
      queryParams: {...url.queryParams, ...queryParams},
      states: {...url.states, ...states},
    );
  }
}
