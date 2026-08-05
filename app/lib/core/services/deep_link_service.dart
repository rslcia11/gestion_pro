import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import '../utils/qr_code_link.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;
  bool _isInitialized = false;
  String? _lastHandledLink;

  Future<void> initialize({
    required void Function(String qrCode) onQrCodeReceived,
  }) async {
    if (_isInitialized) return;
    _isInitialized = true;

    void handle(Uri? uri) {
      if (uri == null) return;
      final link = uri.toString();
      if (link == _lastHandledLink) return;
      _lastHandledLink = link;

      final code = QrCodeLink.extractQrCode(link);
      if (code != null) {
        onQrCodeReceived(code);
      }
    }

    try {
      final initialLink = await _appLinks.getInitialLink();
      handle(initialLink);
    } catch (e) {
      debugPrint('DeepLinkService: error leyendo el link inicial: $e');
    }

    _linkSub = _appLinks.uriLinkStream.listen(
      handle,
      onError: (e) => debugPrint('DeepLinkService: error en uriLinkStream: $e'),
    );
  }

  void dispose() {
    _linkSub?.cancel();
  }
}
