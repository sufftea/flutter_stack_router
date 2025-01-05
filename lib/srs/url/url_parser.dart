// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hyper_router/srs/route/named_route.dart';
import 'package:hyper_router/srs/route/shell_route/shell_route.dart';
import 'package:hyper_router/srs/route/value_route.dart';
import 'package:hyper_router/srs/url/url_data.dart';

abstract class UrlParser<T> {
  UrlData encode(T value);

  (T value, Iterable<String> remainingSegments)? decode(UrlData url);
}

/// {@template UrlSegmentParser}
/// An interface for encoding and decoding the segment of the URL.
///
/// If you enable URL support, you need to specify how some routes should be
/// encoded and decoded from a URL. Currently, this is only necessary for [ValueRoute].
/// [NamedRoute] and [ShellRoute] are able to parse themselves by default and  don't
/// require a custom parser.
///
/// ### Example
/// Here we're creating a parser for `ProductRouteValue`.
/// We want the url to look like this: `home/products/<productID>`.
/// The parser is responsible for the `<productId>` segment:
/// ```dart
/// class ProductSegmentParser extends UrlSegmentParser<ProductRouteValue> {
///   @override
///   ProductRouteValue? decode(SegmentData segment) {
///     return ProductRouteValue(segment.name);
///   }
///
///   @override
///   SegmentData encode(ProductRouteValue value) {
///     return SegmentData(name: value.productId);
///   }
/// }
/// ```
///
/// You can optionally provide query parameters to `SegmentData` (`queryParams` field).
/// They will be placed at the end of the URL. If the stack contains more than one route
/// with query parameters, they'll be combined.
///
/// [decode] should return `null` if it doesn't recognize the segment.
///
/// [SegmentData.state] is stored in the browser's history. You can put the data that you
/// don't want visible in the URL there, and it will be restored when the user navigates
/// using browser's back and forward buttons.
/// {@endtemplate}
abstract class UrlSegmentParser<T> extends UrlParser<T> {
  SegmentData encodeSegment(T value);

  T? decodeSegment(SegmentData segment);

  @override
  UrlData encode(T value) {
    final segment = encodeSegment(value);

    return UrlData(
      segments: [segment.name],
      queryParams: segment.queryParams,
      states: segment.state,
    );
  }

  @override
  (T, Iterable<String>)? decode(UrlData url) {
    final value = decodeSegment(SegmentData(
      name: url.segments.first,
      queryParams: url.queryParams,
      state: url.states,
    ));

    if (value == null) {
      return null;
    }

    return (value, url.segments.skip(1));
  }
}

class SegmentData {
  SegmentData({
    required this.name,
    final Map<String, List<String>>? queryParams,
    final Map<Object, Object?>? state,
  })  : queryParams = queryParams ?? {},
        state = state ?? {};

  final String name;
  final Map<String, List<String>> queryParams;
  final Map<Object, Object?> state;
}
