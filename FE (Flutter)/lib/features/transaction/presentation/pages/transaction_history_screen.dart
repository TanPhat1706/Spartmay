import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spartmay/core/constants/color_constants.dart';
import 'package:spartmay/features/transaction/data/models/transaction_model.dart';
import 'package:spartmay/features/transaction/logic/transaction_provider.dart';
import 'package:spartmay/features/transaction/presentation/widgets/transaction_item.dart';
import 'package:spartmay/core/utils/dialog_utils.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().refreshTransactions();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<TransactionProvider>().loadMoreTransactions();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _shouldShowDateHeader(List<Transaction> list, int index) {
    if (index == 0) return true;
    final currentDate = list[index].date;
    final prevDate = list[index - 1].date;
    
    return currentDate.year != prevDate.year ||
           currentDate.month != prevDate.month ||
           currentDate.day != prevDate.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.backgroundLight,
      appBar: AppBar(
        title: const Text("Lịch sử giao dịch", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              DialogUtils.showComingSoon(context);
            },
          )
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final list = provider.transactions;

          if (list.isEmpty && !provider.isLoadingMore) {
            return const Center(child: Text("Chưa có giao dịch nào"));
          }

          return RefreshIndicator(
            onRefresh: provider.refreshTransactions,
            color: ColorPalette.primaryGreen,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: list.length + (provider.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Hiển thị loading ở cuối danh sách
                if (index == list.length) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ));
                }

                final transaction = list[index];
                final showHeader = _shouldShowDateHeader(list, index);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showHeader) 
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(transaction.date),
                          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ),
                    
                    TransactionItem(transaction: transaction),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}