import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/maintenance_order.dart';
import '../models/order_part.dart';
import '../models/customer.dart';

enum ReportPeriod { daily, weekly, monthly }

class ReportService {
  static Future<void> printSingleOrder(
    MaintenanceOrder order,
    Customer? customer,
    List<OrderPart> parts,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildSingleOrderReport(order, customer, parts),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Order-${order.orderNumber}',
    );
  }

  static pw.Widget _buildSingleOrderReport(
    MaintenanceOrder order,
    Customer? customer,
    List<OrderPart> parts,
  ) {
    final df = DateFormat('yyyy-MM-dd HH:mm');
    final totalParts = parts.fold(0.0, (s, p) => s + p.totalPrice);
    final grandTotal = totalParts + order.laborCost;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Al-Forsan',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text('Maintenance Service Report'),
                pw.Text('Spare Parts & Repair Shop'),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Order #${order.orderNumber}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text('Date: ${df.format(order.receivedAt)}'),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: pw.BoxDecoration(
                    color: _statusColor(order.status),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    order.status.label,
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.Divider(thickness: 1.5),
        pw.SizedBox(height: 8),
        // Customer info
        pw.Text(
          'Customer Information',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Name: ${customer?.name ?? "N/A"}'),
              pw.Text('Phone: ${customer?.phone ?? "N/A"}'),
              if (customer?.email != null && customer!.email!.isNotEmpty)
                pw.Text('Email: ${customer.email}'),
              if (customer?.address != null && customer!.address!.isNotEmpty)
                pw.Text('Address: ${customer.address}'),
            ],
          ),
        ),
        pw.SizedBox(height: 12),
        // Device info
        pw.Text(
          'Device Information',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Type: ${order.deviceType}'),
              pw.Text('Model: ${order.deviceModel}'),
              if (order.serialNumber != null && order.serialNumber!.isNotEmpty)
                pw.Text('Serial: ${order.serialNumber}'),
              pw.Text('Problem: ${order.problemDescription}'),
              if (order.diagnosis != null && order.diagnosis!.isNotEmpty)
                pw.Text('Diagnosis: ${order.diagnosis}'),
            ],
          ),
        ),
        pw.SizedBox(height: 12),
        // Parts used
        pw.Text(
          'Parts Used',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        if (parts.isEmpty)
          pw.Text('No parts used', style: const pw.TextStyle(color: PdfColors.grey))
        else
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _cell('Item', isHeader: true),
                  _cell('SKU', isHeader: true),
                  _cell('Qty', isHeader: true),
                  _cell('Unit Price', isHeader: true),
                  _cell('Total', isHeader: true),
                ],
              ),
              ...parts.map(
                (p) => pw.TableRow(
                  children: [
                    _cell(p.itemName),
                    _cell(p.itemSku),
                    _cell(p.quantity.toString()),
                    _cell('₪ ${p.unitPrice.toStringAsFixed(2)}'),
                    _cell('₪ ${p.totalPrice.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ],
          ),
        pw.SizedBox(height: 12),
        // Totals
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Container(
            width: 200,
            child: pw.Column(
              children: [
                _totalRow('Parts Subtotal', '₪ ${totalParts.toStringAsFixed(2)}'),
                _totalRow('Labor Cost', '₪ ${order.laborCost.toStringAsFixed(2)}'),
                pw.Divider(),
                _totalRow(
                  'Grand Total',
                  '₪ ${grandTotal.toStringAsFixed(2)}',
                  isBold: true,
                ),
              ],
            ),
          ),
        ),
        pw.Spacer(),
        // Footer
        pw.Divider(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated: ${df.format(DateTime.now())}',
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey600,
              ),
            ),
            pw.Text(
              'Al-Forsan',
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Future<void> printPeriodReport({
    required ReportPeriod period,
    required List<MaintenanceOrder> orders,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();
    final df = DateFormat('yyyy-MM-dd');
    final money = NumberFormat.currency(symbol: '₪', decimalDigits: 2);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Al-Forsan',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text('${period.name.toUpperCase()} REPORT'),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Period: ${period.name}'),
                    pw.Text(
                      startDate != null && endDate != null
                          ? '${df.format(startDate)} - ${df.format(endDate)}'
                          : df.format(DateTime.now()),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _statBox('Orders', '${orders.length}'),
                _statBox(
                  'Completed',
                  orders
                      .where(
                        (o) =>
                            o.status == OrderStatus.completed ||
                            o.status == OrderStatus.delivered,
                      )
                      .length
                      .toString(),
                ),
                _statBox(
                  'Revenue',
                  money.format(
                    orders
                        .where(
                          (o) =>
                              o.status == OrderStatus.completed ||
                              o.status == OrderStatus.delivered,
                        )
                        .fold(0.0, (s, o) => s + o.laborCost),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Orders table
          pw.Text(
            'Orders',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          if (orders.isEmpty)
            pw.Text('No orders in this period')
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(1.5),
                4: const pw.FlexColumnWidth(1.5),
                5: const pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _cell('Order #', isHeader: true),
                    _cell('Date', isHeader: true),
                    _cell('Device', isHeader: true),
                    _cell('Status', isHeader: true),
                    _cell('Labor', isHeader: true),
                    _cell('Total', isHeader: true),
                  ],
                ),
                ...orders.map(
                  (o) => pw.TableRow(
                    children: [
                      _cell(o.orderNumber),
                      _cell(df.format(o.receivedAt)),
                      _cell('${o.deviceType}\n${o.deviceModel}'),
                      _cell(o.status.label),
                      _cell('₪ ${o.laborCost.toStringAsFixed(2)}'),
                      _cell(
                        'View\nDetails',
                        style: const pw.TextStyle(
                          color: PdfColors.blue700,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Report-${period.name}-${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  static pw.Widget _cell(String text, {bool isHeader = false, pw.TextStyle? style}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: style ??
            pw.TextStyle(
              fontSize: isHeader ? 10 : 9,
              fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
      ),
    );
  }

  static pw.Widget _totalRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _statBox(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  static PdfColor _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return PdfColors.orange700;
      case OrderStatus.inProgress:
        return PdfColors.blue700;
      case OrderStatus.waitingParts:
        return PdfColors.purple700;
      case OrderStatus.completed:
        return PdfColors.green700;
      case OrderStatus.delivered:
        return PdfColors.green900;
      case OrderStatus.cancelled:
        return PdfColors.red700;
    }
  }
}
