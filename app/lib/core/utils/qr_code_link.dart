class QrCodeLink {
  static const String host = 'donde-siempre-app.s3.us-east-1.amazonaws.com';
  static const String _path = '/index.html';

  /// Arma la URL que se codifica dentro de la imagen del QR de un negocio.
  static String build(String qrCodeUuid) {
    return Uri.https(host, _path, {'qr': qrCodeUuid}).toString();
  }

  /// Dado el string crudo escaneado (cámara interna o deep link), devuelve el
  /// UUID del código. Si es una URL con nuestro host y un query param `qr`,
  /// lo extrae; si no, asume que es un QR viejo (UUID plano) y lo devuelve tal cual.
  static String? extractQrCode(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme && uri.host == host) {
      final qr = uri.queryParameters['qr'];
      return (qr != null && qr.isNotEmpty) ? qr : null;
    }

    return trimmed;
  }
}
