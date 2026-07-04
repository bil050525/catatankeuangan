import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateAndPrintReport(List<Map<String, dynamic>> transactions) async {
    final pdf = pw.Document();
    
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp', 
      decimalDigits: 0
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Laporan Keuangan', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                context: context,
                headers: ['Tanggal', 'Kategori', 'Judul', 'Nominal'],
                data: transactions.map((t) {
                  return [
                    t['date'].toString(),
                    t['category_name'].toString(),
                    t['title'].toString(),
                    '${t['category_type'] == 'income' ? '+' : '-'}${currencyFormatter.format((t['amount'] as num).toDouble())}',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
