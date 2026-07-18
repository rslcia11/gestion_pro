import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gal/gal.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/services/realtime_sync_service.dart';
import 'dart:async';

class QRManagementScreen extends StatefulWidget {
  final String businessId;
  const QRManagementScreen({super.key, required this.businessId});

  @override
  State<QRManagementScreen> createState() => _QRManagementScreenState();
}

// Stub: sin backend conectado — pendiente de integrar nueva DB.
class _QRManagementScreenState extends State<QRManagementScreen> {
  List<Map<String, dynamic>> _qrCodes = [];
  bool _isLoading = true;

  StreamSubscription<void>? _qrCodesSub;

  @override
  void initState() {
    super.initState();
    _loadQRCodes();
    _qrCodesSub = RealtimeSyncService().onQrCodesChanged.listen((_) {
      if (mounted) _loadQRCodes();
    });
  }

  @override
  void dispose() {
    _qrCodesSub?.cancel();
    super.dispose();
  }

  Future<void> _loadQRCodes() async {
    if (!mounted) return;
    setState(() {
      _qrCodes = [];
      _isLoading = false;
    });
  }

  Future<void> _generateFirstQRCode() async {
    setState(() => _isLoading = true);
    final newCode = const Uuid().v4();
    setState(() {
      _qrCodes = [
        {
          'id': newCode,
          'qr_code': newCode,
          'label': 'Código QR Único',
          'created_at': DateTime.now().toUtc().toIso8601String(),
        },
      ];
      _isLoading = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código QR generado exitosamente'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    }
  }


  Future<void> _shareQRImage(String code, String label) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generando y guardando imagen...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {

      final painter = QrPainter(
        data: code,
        version: QrVersions.auto,
        gapless: true,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
      );

      final picRecorder = ui.PictureRecorder();
      final canvas = Canvas(picRecorder);
      
      // Dibujar fondo blanco (900x900)
      final paint = Paint()..color = Colors.white;
      canvas.drawRect(const Rect.fromLTWH(0, 0, 900, 900), paint);
      
      // Dibujar el código QR con algo de padding en el centro
      canvas.translate(50, 50);
      painter.paint(canvas, const Size(800, 800));

      final image = await picRecorder.endRecording().toImage(900, 900);

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final cleanLabel = label
          .replaceAll(RegExp(r'[^\w\s]+'), '')
          .replaceAll(' ', '_');
      final file = await File('${tempDir.path}/qr_$cleanLabel.png').create();
      await file.writeAsBytes(pngBytes);

      // Guardar en galería explícitamente primero
      try {
        final hasAccess = await Gal.hasAccess(toAlbum: true);
        if (!hasAccess) {
          await Gal.requestAccess(toAlbum: true);
        }
        await Gal.putImage(file.path, album: 'Donde Siempre');
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.card),
              ),
              title: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.pastelOf(AppColors.accentGreen),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.circleCheck, color: AppColors.accentGreen, size: 44),
                  ),
                  const SizedBox(height: 16),
                  Text('¡Código guardado!', style: AppTypography.titleBold, textAlign: TextAlign.center),
                ],
              ),
              content: Text(
                'La imagen del código QR se ha guardado correctamente en tu galería de fotos.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
              actions: [
                PrimaryButton(label: 'Listo', onPressed: () => Navigator.pop(context)),
              ],
            ),
          );
        }
      } catch (e) {
        debugPrint('Error guardando en galería: $e');
      }

      if (mounted) {
        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Código QR: $label',
          subject: 'QR Donde Siempre - $label',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al compartir imagen: $e')),
        );
      }
    }
  }

  Future<void> _shareQRPdf(String code, String label) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generando PDF...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final doc = pw.Document();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    label,
                    style: pw.TextStyle(
                      fontSize: 40,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 32),
                  pw.Stack(
                    alignment: pw.Alignment.center,
                    children: [
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(errorCorrectLevel: pw.BarcodeQRCorrectionLevel.high),
                        data: code,
                        width: 300,
                        height: 300,
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    code,
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 32),
                  pw.Text(
                    'Escanea este código para ganar puntos',
                    style: const pw.TextStyle(fontSize: 20),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final bytes = await doc.save();
      final cleanLabel = label
          .replaceAll(RegExp(r'[^\w\s]+'), '')
          .replaceAll(' ', '_');

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ PDF generado. Selecciona "Guardar en Archivos" para enviarlo a Documentos.'),
            backgroundColor: AppColors.accentGreen,
            duration: Duration(seconds: 4),
          ),
        );
      }

      // sharePdf abre nativamente "Guardar en Archivos" o "Compartir por WhatsApp"
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'qr_$cleanLabel.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al generar PDF: $e')));
      }
    }
  }

  void _showQRDialog(String code, String label) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTypography.labelBold.copyWith(fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  boxShadow: AppShadows.card,
                ),
                child: QrImageView(
                  data: code,
                  version: QrVersions.auto,
                  size: 200.0,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                  dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SelectableText(
                'ID: $code',
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Imagen',
                      icon: LucideIcons.image,
                      onPressed: () {
                        Navigator.pop(context);
                        _shareQRImage(code, label);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SecondaryButton(
                      label: 'PDF',
                      icon: LucideIcons.fileText,
                      onPressed: () {
                        Navigator.pop(context);
                        _shareQRPdf(code, label);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(label: 'Listo', onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRegenerateQR(int index, String label) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
        title: Text('Regenerar QR', textAlign: TextAlign.center, style: AppTypography.titleBold),
        content: Text(
          'El código actual dejará de funcionar. ¿Estás seguro?',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: SecondaryButton(label: 'Cancelar', onPressed: () => Navigator.pop(context, false)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PrimaryButton(label: 'Regenerar', isDestructive: true, onPressed: () => Navigator.pop(context, true)),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final newCode = const Uuid().v4();
    setState(() {
      _qrCodes[index]['qr_code'] = newCode;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ QR regenerado correctamente')),
      );
      _showQRDialog(newCode, label);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.accentPurple)))
          : _qrCodes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(color: AppColors.pastelOf(AppColors.accentAmber), shape: BoxShape.circle),
                        child: const Icon(LucideIcons.qrCode, size: 56, color: AppColors.accentAmber),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Sin códigos QR', style: AppTypography.subtitleBold),
                      Text('Genera uno para empezar a recibir clientes.', style: AppTypography.bodyMedium),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                  itemCount: _qrCodes.length,
                  itemBuilder: (context, index) {
                    final qr = _qrCodes[index];
                    final String safeCode = (qr['qr_code'] ?? '').toString();
                    final String safeLabel = (qr['label'] ?? 'QR').toString();
                    final String rawDate = (qr['created_at'] ?? '').toString();
                    final String displayDate = EcuadorDateUtils.formatEcuadorDate(rawDate);
                    final bool isCorrupt = safeCode.isEmpty;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: ModuleListCard(
                        icon: isCorrupt ? LucideIcons.triangleAlert : LucideIcons.qrCode,
                        iconBackgroundColor: isCorrupt ? AppColors.accentPink : AppColors.accentAmber,
                        title: safeLabel,
                        subtitle: isCorrupt ? 'Error en datos' : 'Creado el $displayDate',
                        onTap: () => isCorrupt ? _confirmRegenerateQR(index, safeLabel) : _showQRDialog(safeCode, safeLabel),
                      ),
                    ).animate(delay: (index * 50).ms).fadeIn(duration: 400.ms).slideX(begin: 0.1, curve: Curves.easeOut);
                  },
                ),
      floatingActionButton: (!_isLoading && _qrCodes.isEmpty)
          ? FloatingActionButton.extended(
              onPressed: _generateFirstQRCode,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
              label: Text('Generar mi QR', style: AppTypography.subtitleBold.copyWith(color: AppColors.onPrimary, fontSize: 15)),
              icon: const Icon(LucideIcons.plus),
            )
          : null,
    );
  }
}
