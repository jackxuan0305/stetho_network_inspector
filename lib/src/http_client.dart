import 'dart:async';
import 'dart:io';

import 'http_client_request.dart';
import 'inspector_request.dart';
import 'method_channel_controller.dart';
import 'utils.dart';

class StethoHttpClient implements HttpClient {
  late final HttpClient client;

  StethoHttpClient(this.client);

  @override
  bool autoUncompress = false;

  @override
  Duration idleTimeout = const Duration(seconds: 120);

  @override
  Duration? connectionTimeout;

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  @override
  void addCredentials(
    Uri url,
    String realm,
    HttpClientCredentials credentials,
  ) {
    client.addCredentials(url, realm, credentials);
  }

  @override
  void addProxyCredentials(
    String host,
    int port,
    String realm,
    HttpClientCredentials credentials,
  ) {
    client.addProxyCredentials(host, port, realm, credentials);
  }

  @override
  set authenticate(
    Future<bool> Function(Uri url, String scheme, String? realm)? f,
  ) {
    client.authenticate = f;
  }

  @override
  set authenticateProxy(
    Future<bool> Function(String host, int port, String scheme, String? realm)?
        f,
  ) {
    client.authenticateProxy = f;
  }

  @override
  set badCertificateCallback(
    bool Function(X509Certificate cert, String host, int port)? callback,
  ) {
    client.badCertificateCallback = callback;
  }

  @override
  void close({bool force = false}) {
    client.close();
  }

  @override
  Future<HttpClientRequest> get(String host, int port, String path) =>
      open("get", host, port, path);

  @override
  Future<HttpClientRequest> getUrl(Uri url) => openUrl("get", url);

  @override
  Future<HttpClientRequest> post(String host, int port, String path) =>
      open("post", host, port, path);

  @override
  Future<HttpClientRequest> postUrl(Uri url) => openUrl("post", url);

  @override
  Future<HttpClientRequest> put(String host, int port, String path) =>
      open("put", host, port, path);

  @override
  Future<HttpClientRequest> putUrl(Uri url) => openUrl("put", url);

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) =>
      open("delete", host, port, path);

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) => openUrl("delete", url);

  @override
  Future<HttpClientRequest> head(String host, int port, String path) =>
      open("head", host, port, path);

  @override
  Future<HttpClientRequest> headUrl(Uri url) => openUrl("head", url);

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) =>
      open("patch", host, port, path);

  @override
  Future<HttpClientRequest> patchUrl(Uri url) => openUrl("patch", url);

  @override
  set findProxy(String Function(Uri url)? f) => client.findProxy = f;

  @override
  Future<HttpClientRequest> open(
    String method,
    String host,
    int port,
    String path,
  ) async {
    Uri uri = Uri(host: host, port: port, path: path);
    return await openUrl(method, uri);
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return client.openUrl(method, url).then((request) {
      final wrapped = _wrapResponse(request);
      List<int> body = [];
      if (method.toLowerCase() != 'post' && method.toLowerCase() != 'put') {
        scheduleMicrotask(() {
          MethodChannelController.requestWillBeSent(
            new FlutterStethoInspectorRequest(
              url: request.uri.toString(),
              headers: headersToMap(request.headers),
              method: request.method,
              id: wrapped.id,
              body: body,
            ),
          );
        });
      } else {
        wrapped.stream.listen((onData) {
          body.addAll(onData);
          scheduleMicrotask(() {
            MethodChannelController.requestWillBeSent(
              new FlutterStethoInspectorRequest(
                url: request.uri.toString(),
                headers: headersToMap(request.headers),
                method: request.method,
                id: wrapped.id,
                body: body,
              ),
            );
          });
        });
      }

      return wrapped;
    });
  }

  StethoHttpClientRequest _wrapResponse(HttpClientRequest request) {
    final id = new Uuid().generateV4();

    return new StethoHttpClientRequest(request, id);
  }

  @override
  set connectionFactory(
      Future<ConnectionTask<Socket>> Function(
              Uri url, String? proxyHost, int? proxyPort)?
          f) {
    client.connectionFactory = f;
  }

  @override
  set keyLog(Function(String line)? callback) {
    client.keyLog = callback;
  }
}
