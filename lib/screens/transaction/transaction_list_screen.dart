// screens/transaction/transaction_list_screen.dart

import 'package:flutter/material.dart';

import '../../models/transaction.dart';
import '../../repositories/transaction_repository.dart';
import 'transaction_detail_screen.dart';

class TransactionListScreen extends StatefulWidget {
  final String salesOrderName;

  const TransactionListScreen({super.key, required this.salesOrderName});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  List<TransactionModel> transactions = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  // ============================================================
  // LOAD PAYMENT ENTRIES
  // ============================================================

  Future<void> _loadTransactions() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final repository = TransactionRepository();

      final allPayments = await repository.getMyPaymentEntries();

      // --------------------------------------------------------
      // ONLY PAYMENTS LINKED TO CURRENT SALES ORDER
      // --------------------------------------------------------

      final filteredPayments = allPayments.where((payment) {
        return payment.references.any(
          (reference) =>
              reference.referenceDoctype.toLowerCase() == "sales order" &&
              reference.referenceName == widget.salesOrderName,
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        transactions = filteredPayments;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("GET PAYMENT ENTRIES ERROR: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
        transactions = [];
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041A1F),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Transactions",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF041A1F),
              Color(0xFF073D3A),
              Color(0xFF0B5E4D),
              Color(0xFF102F2D),
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSalesOrderHeader(),

              const SizedBox(height: 12),

              Expanded(child: _buildTransactionContent()),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TRANSACTION CONTENT
  // ============================================================

  Widget _buildTransactionContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF7EE787)),
      );
    }

    if (transactions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: const Color(0xFF7EE787),
      backgroundColor: const Color(0xFF073D3A),
      onRefresh: _loadTransactions,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
        itemCount: transactions.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final transaction = transactions[index];

          return _buildTransactionCard(context, transaction);
        },
      ),
    );
  }

  // ============================================================
  // SALES ORDER HEADER
  // ============================================================

  Widget _buildSalesOrderHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 5),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF1DB954).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFF7EE787),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sales Order",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    widget.salesOrderName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TRANSACTION CARD
  // ============================================================

  Widget _buildTransactionCard(
    BuildContext context,
    TransactionModel transaction,
  ) {
    final amount = transaction.paidAmount > 0
        ? transaction.paidAmount
        : transaction.receivedAmount;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionDetailScreen(transaction: transaction),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Row(
          children: [
            // --------------------------------------------------
            // PAYMENT ICON
            // --------------------------------------------------
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1DB954).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.payments_rounded,
                color: Color(0xFF7EE787),
                size: 24,
              ),
            ),

            const SizedBox(width: 13),

            // --------------------------------------------------
            // PAYMENT INFORMATION
            // --------------------------------------------------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.partyName.isNotEmpty
                        ? transaction.partyName
                        : transaction.party,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    transaction.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 10,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        color: Color(0xFF7EE787),
                        size: 14,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        transaction.postingDate,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 10,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Color(0xFF7EE787),
                        size: 14,
                      ),

                      const SizedBox(width: 5),

                      Expanded(
                        child: Text(
                          transaction.modeOfPayment.isNotEmpty
                              ? transaction.modeOfPayment
                              : "-",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // --------------------------------------------------
            // AMOUNT + STATUS
            // --------------------------------------------------
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹ ${amount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Color(0xFF7EE787),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 7),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DB954).withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    transaction.status.isNotEmpty ? transaction.status : "-",
                    style: const TextStyle(
                      color: Color(0xFF7EE787),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 7),

                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white38,
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF1DB954).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: Color(0xFF7EE787),
                size: 34,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "No Transactions Found",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "No payment entries are linked to this Sales Order.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.50),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
