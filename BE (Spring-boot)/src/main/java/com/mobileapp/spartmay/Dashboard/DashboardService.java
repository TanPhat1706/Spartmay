// package com.mobileapp.spartmay.Dashboard;

// import java.time.format.DateTimeFormatter;
// import java.util.List;
// import java.util.stream.Collectors;

// import org.springframework.data.domain.PageRequest;
// import org.springframework.stereotype.Service;

// import com.mobileapp.spartmay.Transaction.TransactionRepository;
// import com.mobileapp.spartmay.User.User;
// import com.mobileapp.spartmay.Wallet.WalletRepository;

// import lombok.RequiredArgsConstructor;

// @Service
// @RequiredArgsConstructor
// public class DashboardService {
//     private final WalletRepository walletRepository;
//     private final TransactionRepository transactionRepository;

//     public DashboardResponse getDashboardData(User user) {
//         Double totalBalance = walletRepository.sumBalanceByUser(user);
//         Double totalIncome = transactionRepository.sumIncomeByUser(user);
//         Double totalExpense = transactionRepository.sumExpenseByUser(user);

//         if (totalBalance == null) totalBalance = 0.0;
//         if (totalIncome == null) totalIncome = 0.0;
//         if (totalExpense == null) {
//             totalExpense = 0.0;
//         } else {
//             totalExpense = -totalExpense;
//         }

//         var recentTx = transactionRepository.findAllByUserOrderByDateDesc(user, PageRequest.of(0, 5));

//         DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm dd/MM");

//         List<DashboardResponse.TransactionDto> txDtos = recentTx.stream().limit(4).map(tx ->
//             DashboardResponse.TransactionDto.builder()
//                 .id(tx.getId())
//                 .title(tx.getCategory() != null ? tx.getCategory().getName() : tx.getNote())
//                 .amount(tx.getAmount())
//                 .note(tx.getNote())
//                 .date(tx.getDate().format(formatter))
//                 .icon(tx.getCategory() != null ? tx.getCategory().getIcon() : "default")
//                 .categoryName(tx.getCategory() != null ? tx.getCategory().getName() : "Khác")
//                 .build()
//         ).collect(Collectors.toList());

//         return DashboardResponse.builder()
//             .totalBalance(totalBalance)
//             .totalIncome(totalIncome)
//             .totalExpense(totalExpense)
//             .recentTransactions(txDtos)
//             .build();
//     }
// }
