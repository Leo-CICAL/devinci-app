import 'dart:io';

void l(var msg) {
  //stand for log

  //app is not in release mode
  print(msg);
}

Future<HttpClientResponse> devinciRequest(var tokens,
    {String endpoint,
    String method = 'GET',
    bool followRedirects = false,
    List<List<String>> headers,
    String data,
    String replacementUrl = '',
    bool log = false}) async {
  if (tokens['SimpleSAML'] != '' &&
      tokens['alv'] != '' &&
      tokens['uids'] != '' &&
      tokens['SimpleSAMLAuthToken'] != '') {
    var client = HttpClient();
    if (log) print('[0]');
    var uri = Uri.parse(replacementUrl == ''
        ? 'https://www.leonard-de-vinci.net/' + endpoint
        : replacementUrl);
    if (log) print('[1] ${endpoint}');
    var req =
        method == 'GET' ? await client.getUrl(uri) : await client.postUrl(uri);
    if (log) print('[1] ${req}');
    req.followRedirects = followRedirects;
    req.cookies.addAll([
      Cookie('alv', tokens['alv']),
      Cookie('SimpleSAML', tokens['SimpleSAML']),
      Cookie('uids', tokens['uids']),
      Cookie('SimpleSAMLAuthToken', tokens['SimpleSAMLAuthToken']),
    ]);
    if (headers != null) {
      for (var header in headers) {
        req.headers.set(header[0], header[1]);
      }
    }
    if (data != null) {
      req.write(data);
    }
    if (log) print('[2]');
    return await req.close();
  } else {
    return null;
  }
}
