// services/payment_receipt_service.dart

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/transaction.dart';

class PaymentReceiptService {
  static Future<void> generateReceipt(TransactionModel transaction) async {
    final pdf = pw.Document();

    // Load receipt images from assets.
    final logoData = await rootBundle.load('assets/Madathilogo.png');
    final logo = pw.MemoryImage(logoData.buffer.asUint8List());

    final sealData = await rootBundle.load('assets/seal.jpeg');
    final seal = pw.MemoryImage(sealData.buffer.asUint8List());

    final signatureData = await rootBundle.load('assets/signature.jpeg');
    final signature = pw.MemoryImage(signatureData.buffer.asUint8List());

    // Transaction information.
    final double amount = transaction.paidAmount > 0
        ? transaction.paidAmount
        : transaction.receivedAmount;

    final String customerName = transaction.partyName.isNotEmpty
        ? transaction.partyName
        : transaction.party;

    // Customer address fetched from ERPNext.
    final String customerAddress = transaction.customerAddress.trim();

    final String salesOrder = transaction.references.isNotEmpty
        ? transaction.references.first.referenceName
        : '-';

    final String amountInWords = _amountInWords(amount);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return pw.Container(
            width: double.infinity,
            height: double.infinity,
            padding: const pw.EdgeInsets.all(18),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey600, width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Company header.
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.SizedBox(
                      width: 72,
                      height: 60,
                      child: pw.Image(logo, fit: pw.BoxFit.contain),
                    ),
                    pw.SizedBox(width: 14),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'MADATHIL SOLAR',
                            style: pw.TextStyle(
                              fontSize: 21,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green800,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            transaction.company.isNotEmpty
                                ? transaction.company
                                : 'Madathil Marketing Company Private Limited',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'Kuriyayi Building, Sahakarana Road, Vyttila',
                            style: const pw.TextStyle(
                              fontSize: 8,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.green800,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        'PAYMENT RECEIPT',
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 12),

                pw.Container(
                  height: 2,
                  width: double.infinity,
                  color: PdfColors.green800,
                ),

                pw.SizedBox(height: 18),

                // Receipt number and date.
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: _lineField('Receipt No', transaction.name),
                    ),
                    pw.SizedBox(width: 30),
                    pw.Expanded(
                      flex: 2,
                      child: _lineField('Date', transaction.postingDate),
                    ),
                  ],
                ),

                pw.SizedBox(height: 18),

                // Customer name.
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Received with thanks from',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: _underlineField(customerName, fontSize: 11),
                    ),
                  ],
                ),

                // Customer address.
                pw.SizedBox(height: 10),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(
                      width: 112,
                      child: pw.Text(
                        'Customer Address:',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.only(bottom: 4),
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                              color: PdfColors.grey600,
                              width: 0.7,
                            ),
                          ),
                        ),
                        child: pw.Text(
                          customerAddress.isNotEmpty ? customerAddress : '-',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 18),

                // Amount and amount in words.
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Amount',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Container(
                      width: 175,
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          color: PdfColors.green800,
                          width: 1,
                        ),
                        borderRadius: pw.BorderRadius.circular(3),
                      ),
                      child: pw.Text(
                        'Rs. ${amount.toStringAsFixed(2)}',
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green800,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 22),
                    pw.Text('In words', style: const pw.TextStyle(fontSize: 9)),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: _underlineField(amountInWords, fontSize: 9),
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),

                // Payment details. Payment Status is intentionally omitted.
                pw.Text(
                  'Payment Details',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green800,
                  ),
                ),

                pw.SizedBox(height: 8),

                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey500, width: 0.7),
                  ),
                  child: pw.Column(
                    children: [
                      _receiptDetailRow(
                        'Payment Mode',
                        transaction.modeOfPayment,
                      ),
                      _receiptDetailRow(
                        'Reference No',
                        transaction.referenceNo,
                      ),
                      _receiptDetailRow(
                        'Reference Date',
                        transaction.referenceDate,
                      ),
                      _receiptDetailRow(
                        'Sales Order',
                        salesOrder,
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 18),

                // Payment purpose.
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('For', style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: _underlineField(
                        salesOrder == '-'
                            ? 'Customer Payment'
                            : 'Sales Order $salesOrder',
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),

                // Use remaining vertical space before the signature.
                pw.Spacer(),

                // Seal and authorized signature.
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.SizedBox(
                      width: 100,
                      height: 78,
                      child: pw.Image(seal, fit: pw.BoxFit.contain),
                    ),
                    pw.SizedBox(width: 28),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.SizedBox(
                          width: 145,
                          height: 48,
                          child: pw.Image(signature, fit: pw.BoxFit.contain),
                        ),
                        pw.Container(
                          width: 155,
                          height: 1,
                          color: PdfColors.grey700,
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Authorized Signature',
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 12),

                pw.Center(
                  child: pw.Text(
                    'Thank you for your payment',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Save the generated PDF.
    final directory = await getApplicationDocumentsDirectory();

    final file = File(
      '${directory.path}/Payment_Receipt_${transaction.name}.pdf',
    );

    await file.writeAsBytes(await pdf.save());

    // Open the receipt.
    await OpenFilex.open(file.path);
  }

  static pw.Widget _lineField(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text('$label:', style: const pw.TextStyle(fontSize: 9)),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 4),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey600, width: 0.7),
              ),
            ),
            child: pw.Text(
              value.isEmpty ? '-' : value,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _underlineField(String value, {double fontSize = 9}) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey600, width: 0.7),
        ),
      ),
      child: pw.Text(
        value.isEmpty ? '-' : value,
        style: pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _receiptDetailRow(
    String label,
    String value, {
    bool isLast = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 7),
      decoration: isLast
          ? null
          : const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 115,
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ),
          pw.Text(':', style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Text(
              value.isEmpty ? '-' : value,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static String _amountInWords(double amount) {
    final int rupees = amount.floor();
    final int paise = ((amount - rupees) * 100).round();

    if (rupees == 0 && paise == 0) {
      return 'Zero Rupees Only';
    }

    String result = '';

    if (rupees > 0) {
      result = '${_convertNumber(rupees)} Rupees';
    }

    if (paise > 0) {
      result += ' and ${_convertNumber(paise)} Paise';
    }

    return '$result Only';
  }

  static String _convertNumber(int number) {
    if (number == 0) {
      return 'Zero';
    }

    const List<String> ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen',
    ];

    const List<String> tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety',
    ];

    String convertBelowThousand(int n) {
      String result = '';

      if (n >= 100) {
        result += '${ones[n ~/ 100]} Hundred';
        n %= 100;

        if (n > 0) {
          result += ' ';
        }
      }

      if (n >= 20) {
        result += tens[n ~/ 10];
        n %= 10;

        if (n > 0) {
          result += ' ${ones[n]}';
        }
      } else if (n > 0) {
        result += ones[n];
      }

      return result;
    }

    String result = '';

    if (number >= 10000000) {
      result += '${convertBelowThousand(number ~/ 10000000)} Crore';
      number %= 10000000;

      if (number > 0) {
        result += ' ';
      }
    }

    if (number >= 100000) {
      result += '${convertBelowThousand(number ~/ 100000)} Lakh';
      number %= 100000;

      if (number > 0) {
        result += ' ';
      }
    }

    if (number >= 1000) {
      result += '${convertBelowThousand(number ~/ 1000)} Thousand';
      number %= 1000;

      if (number > 0) {
        result += ' ';
      }
    }

    if (number > 0) {
      result += convertBelowThousand(number);
    }

    return result.trim();
  }
}
