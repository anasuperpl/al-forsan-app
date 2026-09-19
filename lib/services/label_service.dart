import 'package:barcode_widget/barcode_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/item.dart';

class LabelService {
  // 10cm x 5cm = ~283 x ~141 points (1cm = 28.35pt)
  static const double labelWidthCm = 10;
  static const double labelHeightCm = 5;

  static Future<void> printLabel(Item item, {bool single = true}) async {
    final labelWidget = _buildLabelWidget(item);

    if (single) {
      await Printing.layoutPdf(
        onLayout: (format) async => labelWidget,
        name: 'Label-${item.sku}',
      );
    } else {
      await Printing.layoutPdf(
        onLayout: (format) async => labelWidget,
        name: 'Labels-Batch',
      );
    }
  }

  static Future<void> printBatchLabels(List<Item> items) async {
    final labels = <pw.Widget>[];
    for (final item in items) {
      labels.add(_buildLabelContent(item));
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          labelWidthCm * PdfPageFormat.cm,
          labelHeightCm * PdfPageFormat.cm,
          marginAll: 2 * PdfPageFormat.mm,
        ),
        build: (context) {
          if (items.length == 1) {
            return _buildLabelContent(items.first);
          }
          return pw.Wrap(
            children: labels,
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Labels-Batch-${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  static pw.Document _buildLabelWidget(Item item) {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          labelWidthCm * PdfPageFormat.cm,
          labelHeightCm * PdfPageFormat.cm,
          marginAll: 2 * PdfPageFormat.mm,
        ),
        build: (context) => _buildLabelContent(item),
      ),
    );
    return pdf;
  }

  static pw.Widget _buildLabelContent(Item item) {
    return pw.Container(
      width: labelWidthCm * PdfPageFormat.cm,
      height: labelHeightCm * PdfPageFormat.cm,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.5),
      ),
      padding: const pw.EdgeInsets.all(2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header with shop name
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Al-Forsan',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                '₪ ${item.salePrice.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.red700,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 1),
          // Item name
          pw.Text(
            item.name,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
            maxLines: 1,
            overflow: pw.TextOverflow.clip,
          ),
          if (item.category.isNotEmpty)
            pw.Text(
              item.category,
              style: const pw.TextStyle(
                fontSize: 7,
                color: PdfColors.grey700,
              ),
              maxLines: 1,
            ),
          pw.Spacer(),
          // Barcode
          pw.Center(
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.code128(),
              data: item.sku,
              width: 70,
              height: 22,
              drawText: true,
            ),
          ),
          pw.SizedBox(height: 1),
          // Footer
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'SKU: ${item.sku}',
                style: const pw.TextStyle(fontSize: 6),
              ),
              pw.Text(
                DateTime.now().toString().split(' ')[0],
                style: const pw.TextStyle(
                  fontSize: 6,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
