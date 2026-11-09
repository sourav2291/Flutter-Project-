// screens/transaction/transaction_detail_screen.dart

import 'package:flutter/material.dart';

import '../../models/transaction.dart';
import '../../services/payment_receipt_service.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),
      appBar: AppBar(
        title: const Text(
          "Transaction Details",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF0B7A53),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAmountCard(),

            const SizedBox(height: 16),

            _buildTransactionInfoCard(),

            const SizedBox(height: 16),

            _buildPaymentInfoCard(),

            const SizedBox(height: 16),

            _buildReferenceCard(),

            const SizedBox(height: 24),

            // Show receipt only for submitted Payment Entries.
            if (transaction.docstatus == 1)
              _buildDownloadReceiptButton(context)
            else
              _buildReceiptUnavailableMessage(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // AMOUNT CARD
  // ============================================================

  Widget _buildAmountCard() {
    final double amount = transaction.paidAmount > 0
        ? transaction.paidAmount
        : transaction.receivedAmount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B7A53),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Transaction Amount",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            "₹${amount.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              transaction.customStatusOfPayment.isEmpty
                  ? "-"
                  : transaction.customStatusOfPayment,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TRANSACTION INFORMATION
  // ============================================================

  Widget _buildTransactionInfoCard() {
    return _buildCard(
      title: "Transaction Information",
      children: [
        _buildInfoRow("Payment Entry", transaction.name),
        _buildInfoRow("Payment Type", transaction.paymentType),
        _buildInfoRow("Party Type", transaction.partyType),
        _buildInfoRow("Party", transaction.party),
        _buildInfoRow("Party Name", transaction.partyName),
        _buildInfoRow("Posting Date", transaction.postingDate),
        _buildInfoRow(
          "Status",
          transaction.customStatusOfPayment,
          isLast: true,
        ),
      ],
    );
  }

  // ============================================================
  // PAYMENT INFORMATION
  // ============================================================

  Widget _buildPaymentInfoCard() {
    return _buildCard(
      title: "Payment Information",
      children: [
        _buildInfoRow(
          "Paid Amount",
          "₹ ${transaction.paidAmount.toStringAsFixed(2)}",
        ),
        _buildInfoRow(
          "Received Amount",
          "₹ ${transaction.receivedAmount.toStringAsFixed(2)}",
        ),
        _buildInfoRow("Payment Mode", transaction.modeOfPayment),
        _buildInfoRow("Paid From", transaction.paidFrom),
        _buildInfoRow("Paid To", transaction.paidTo),
        _buildInfoRow("Reference No", transaction.referenceNo),
        _buildInfoRow("Reference Date", transaction.referenceDate),
        _buildInfoRow("Company", transaction.company),
        _buildInfoRow("Remarks", transaction.remarks, isLast: true),
      ],
    );
  }

  // ============================================================
  // SALES ORDER REFERENCE
  // ============================================================

  Widget _buildReferenceCard() {
    final references = transaction.references;

    return _buildCard(
      title: "Sales Order Reference",
      children: [
        if (references.isEmpty)
          _buildInfoRow("Reference", "-", isLast: true)
        else
          ...references.asMap().entries.map((entry) {
            final index = entry.key;
            final reference = entry.value;

            return Column(
              children: [
                _buildInfoRow("Reference Type", reference.referenceDoctype),
                _buildInfoRow("Reference Name", reference.referenceName),
                _buildInfoRow(
                  "Total Amount",
                  "₹ ${reference.totalAmount.toStringAsFixed(2)}",
                ),
                _buildInfoRow(
                  "Outstanding",
                  "₹ ${reference.outstandingAmount.toStringAsFixed(2)}",
                ),
                _buildInfoRow(
                  "Allocated Amount",
                  "₹ ${reference.allocatedAmount.toStringAsFixed(2)}",
                  isLast: index == references.length - 1,
                ),
              ],
            );
          }),
      ],
    );
  }

  // ============================================================
  // COMMON CARD
  // ============================================================

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B7A53),
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // INFORMATION ROW
  // ============================================================

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 125,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value.isEmpty ? "-" : value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),
      ],
    );
  }

  // ============================================================
  // RECEIPT UNAVAILABLE MESSAGE
  // ============================================================

  Widget _buildReceiptUnavailableMessage() {
    final bool isCancelled = transaction.docstatus == 2;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCancelled
            ? Colors.red.withValues(alpha: 0.08)
            : Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCancelled
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCancelled ? Icons.cancel_outlined : Icons.hourglass_empty_rounded,
            color: isCancelled ? Colors.red : Colors.orange.shade800,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isCancelled
                  ? "Receipt unavailable: Payment Entry is cancelled."
                  : "Receipt will be available after the Payment Entry "
                        "is submitted by an authorized person.",
              style: TextStyle(
                color: isCancelled ? Colors.red : Colors.orange.shade900,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DOWNLOAD RECEIPT
  // ============================================================

  Widget _buildDownloadReceiptButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          // Recheck the submission status before generating the receipt.
          if (transaction.docstatus != 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Receipt is available only for submitted Payment Entries.",
                ),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          try {
            await PaymentReceiptService.generateReceipt(transaction);
          } catch (e) {
            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Failed to generate receipt: $e"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        icon: const Icon(Icons.download_rounded),
        label: const Text(
          "Download Receipt",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B7A53),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
