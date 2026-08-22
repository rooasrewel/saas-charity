import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas/core/app_theme.dart';
import '../../../../services/chat_service.dart';
import '../../data/donner_repository.dart';
import '../../logic/donner_bloc.dart';
import '../../logic/donner_event.dart';
import '../../logic/donner_state.dart';

import 'top_up_page.dart';

class DonorWalletPage extends StatelessWidget {
  const DonorWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTitleColor = isDark ? AppTheme.textGreyDark : AppTheme.textGrey;

    return BlocProvider(
      create: (context) => DonnerBloc(DonnerRepository('http://10.0.2.2:8000/api'), ChatService(),)..add(FetchWalletDetails()),
      child: Scaffold(
        body: BlocBuilder<DonnerBloc, DonnerState>(
          builder: (context, state) {
            if (state is DonnerLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DonnerError) {
              return Center(
                child: Text(state.message, style: const TextStyle(color: Colors.red)),
              );
            }

            if (state is WalletLoaded) {
              final wallet = state.wallet;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. كرت الرصيد الحالي بتدرج لوني مائل ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xff0d9488),
                            Color(0xff2dd4bf),
                            Color(0xff38bdf8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff0d9488).withOpacity(0.25),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CURRENT BALANCE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // عرض الرصيد الحقيقي القادم من الباك إند
                          Text(
                            '\$${wallet.balance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Account Status',
                                    style: TextStyle(color: Colors.white60, fontSize: 12),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Active Wallet',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final isSuccess = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const TopUpPage()),
                                  );

                                  if (isSuccess == true && context.mounted) {
                                    context.read<DonnerBloc>().add(FetchWalletDetails());
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xff0d9488),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Top Up',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // --- 2. كروت الإحصائيات السريعة ---
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? const Color(0xff405954) : const Color(0xffe2e8f0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  color: isDark ? AppTheme.primaryDark : const Color(0xff0f766e),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${wallet.transactions.length} Total Txns',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // --- 3. سجل العمليات المالي ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transaction History',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // عرض قائمة الحركات المالية الفردية القادمة من الباك إند
                    if (wallet.transactions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: Text('No transactions yet')),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: wallet.transactions.length,
                        itemBuilder: (context, index) {
                          final tx = wallet.transactions[index];
                          final isDeposit = tx.type == 'deposit';

                          return _buildTransactionItem(
                            context: context,
                            icon: isDeposit ? Icons.add : Icons.favorite,
                            iconColor: isDeposit ? const Color(0xff0f766e) : const Color(0xff0284c7),
                            bgColor: isDeposit
                                ? (isDark ? const Color(0xff0f766e).withOpacity(0.2) : const Color(0xffccfbf1))
                                : (isDark ? const Color(0xff0369a1).withOpacity(0.2) : const Color(0xffe0f2fe)),
                            title: isDeposit ? 'Wallet Top-up' : 'Donation',
                            date: tx.createdAt,
                            amount: '${isDeposit ? "+" : "-"}\$${tx.amount.toStringAsFixed(2)}',
                            amountColor: isDeposit
                                ? (isDark ? AppTheme.primaryDark : const Color(0xff0f766e))
                                : const Color(0xffef4444),
                            status: 'Completed',
                            subTitleColor: subTitleColor,
                          );
                        },
                      ),
                  ],
                ),
              );
            }

            return const Center(child: Text('Pull to refresh'));
          },
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String date,
    required String amount,
    required Color amountColor,
    required String status,
    required Color subTitleColor,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(color: subTitleColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: TextStyle(
                      color: amountColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(color: subTitleColor, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xff405954).withOpacity(0.5)
              : const Color(0xffe2e8f0),
          height: 1,
        ),
      ],
    );
  }
}