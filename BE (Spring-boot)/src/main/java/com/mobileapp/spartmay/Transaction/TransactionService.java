package com.mobileapp.spartmay.Transaction;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.mobileapp.spartmay.Category.Category;
import com.mobileapp.spartmay.Category.CategoryRepository;
import com.mobileapp.spartmay.Stat.MonthlyStatResponse;
import com.mobileapp.spartmay.User.User;
import com.mobileapp.spartmay.Wallet.Wallet;
import com.mobileapp.spartmay.Wallet.WalletRepository;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class TransactionService {
    private final TransactionRepository transactionRepository;
    private final WalletRepository walletRepository;
    private final CategoryRepository categoryRepository;

    public List<Category> getAllCategories() {
        return categoryRepository.findAll();
    }

    @Transactional
    public Transaction createTransaction(TransactionRequest request, User user) {
        Wallet wallet = walletRepository.findById(request.getWalletId())
                .orElseThrow(() -> new RuntimeException("Ví không tồn tại"));
        System.out.println("Wallet: " + wallet);
        if (!wallet.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Bạn không có quyền thực hiện thao tác này");
        }

        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new RuntimeException("Danh mục không tồn tại"));
        System.out.println("Category: " + category.getType());

        Double amount;
        if (category.getType().equals(Category.CategoryType.INCOME)) {
            amount = request.getAmount();
        } else if (category.getType().equals(Category.CategoryType.EXPENSE)) {
            amount = -request.getAmount();
        } else {
            throw new RuntimeException("Loại danh mục không hợp lệ");
        }

        Transaction transaction = Transaction.builder()
                .amount(amount)
                .note(request.getNote())
                .date(request.getDate())
                .category(category)
                .wallet(wallet)
                .user(user)
                .build();
        
        wallet.setBalance(wallet.getBalance() + amount);
        walletRepository.save(wallet);
        System.out.println("Transaction: " + transaction);
        return transactionRepository.save(transaction);
    }

    public Page<Transaction> getTransactions(User user, LocalDate date, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);

        if (date != null) {
            LocalDateTime startOfDay = date.atStartOfDay();
            LocalDateTime endOfDay = date.atTime(LocalTime.MAX);
            return transactionRepository.findByUserAndDateBetween(user, startOfDay, endOfDay, pageable);
        } else {
            return transactionRepository.findAllByUserOrderByDateDesc(user, pageable);
        }   
    }

    @Transactional
    public Transaction updateTransaction(Long id, TransactionRequest request, User user) {
        Transaction transaction = transactionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Giao dịch không tồn tại"));

        if (!transaction.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Bạn không có quyền sửa giao dịch này");
        }

        Wallet oldWallet = transaction.getWallet();
        oldWallet.setBalance(oldWallet.getBalance() - transaction.getAmount());
        walletRepository.save(oldWallet);

        Wallet targetWallet = oldWallet;
        if (!request.getWalletId().equals(oldWallet.getId())) {
             targetWallet = walletRepository.findById(request.getWalletId())
                    .orElseThrow(() -> new RuntimeException("Ví mới không tồn tại"));
             if (!targetWallet.getUser().getId().equals(user.getId())) {
                 throw new RuntimeException("Ví không hợp lệ");
             }
        }

        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new RuntimeException("Danh mục không tồn tại"));

        Double newAmount;
        if (category.getType().equals(Category.CategoryType.INCOME)) {
            newAmount = request.getAmount();
        } else {
            newAmount = -request.getAmount();
        }

        transaction.setAmount(newAmount);
        transaction.setNote(request.getNote());
        transaction.setDate(request.getDate());
        transaction.setCategory(category);
        transaction.setWallet(targetWallet);

        targetWallet.setBalance(targetWallet.getBalance() + newAmount);
        walletRepository.save(targetWallet);

        return transactionRepository.save(transaction);
    }

    public MonthlySummaryResponse getMonthlySummary(User user, int month, int year) {
        YearMonth yearMonth = YearMonth.of(year, month);
        LocalDateTime startOfMonth = yearMonth.atDay(1).atStartOfDay();
        LocalDateTime endOfMonth = yearMonth.atEndOfMonth().atTime(LocalTime.MAX);

        List<Transaction> transactions = transactionRepository.findByUserAndDateBetween(user, startOfMonth, endOfMonth);

        double totalIncome = transactions.stream()
                .mapToDouble(Transaction::getAmount)
                .filter(amount -> amount > 0)
                .sum();

        double totalExpense = transactions.stream()
                .mapToDouble(Transaction::getAmount)
                .filter(amount -> amount < 0)
                .sum();

        Map<LocalDate, List<Transaction>> transactionsByDay = transactions.stream()
                .collect(Collectors.groupingBy(t -> t.getDate().toLocalDate()));

        List<MonthlySummaryResponse.DailyStat> dailyStats = new ArrayList<>();

        transactionsByDay.forEach((date, dailyTxList) -> {
            double dailyIncome = dailyTxList.stream()
                    .mapToDouble(Transaction::getAmount)
                    .filter(a -> a > 0)
                    .sum();

            double dailyExpense = dailyTxList.stream()
                    .mapToDouble(Transaction::getAmount)
                    .filter(a -> a < 0)
                    .sum();

            dailyStats.add(MonthlySummaryResponse.DailyStat.builder()
                    .date(date)
                    .income(dailyIncome)
                    .expense(dailyExpense)
                    .build());
        });
        
        dailyStats.sort((a, b) -> a.getDate().compareTo(b.getDate()));

        return MonthlySummaryResponse.builder()
                .totalIncome(totalIncome)
                .totalExpense(totalExpense)
                .dailyStats(dailyStats)
                .build();
    }

    @Transactional
    public void deleteTransaction(Long id, User user) {
        Transaction transaction = transactionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Giao dịch không tồn tại"));
        
        if (!transaction.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Bạn không có quyền thực hiện thao tác này");
        }

        Wallet wallet = transaction.getWallet();
        wallet.setBalance(wallet.getBalance() - transaction.getAmount());
        
        walletRepository.save(wallet);
        transactionRepository.delete(transaction);
    }

    public List<MonthlyStatResponse> getStatistics(User user, int month, int year, String typeStr) {
        
        Category.CategoryType type;
        try {
            type = Category.CategoryType.valueOf(typeStr.toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Loại thống kê không hợp lệ (Phải là INCOME hoặc EXPENSE)");
        }

        YearMonth yearMonth = YearMonth.of(year, month);
        LocalDateTime startOfMonth = yearMonth.atDay(1).atStartOfDay();
        LocalDateTime endOfMonth = yearMonth.atEndOfMonth().atTime(LocalTime.MAX);

        List<MonthlyStatResponse> stats = transactionRepository.getMonthlyStatsByType(user, startOfMonth, endOfMonth, type);

        for (MonthlyStatResponse stat : stats) {
            stat.setColorHex(getColorForCategory(stat.getCategoryName()));
            stat.setAmount(Math.abs(stat.getAmount())); 
        }
        
        stats.sort((a, b) -> b.getAmount().compareTo(a.getAmount()));

        return stats;
    }

    private String getColorForCategory(String categoryName) {
        switch (categoryName.toLowerCase()) {
            case "ăn uống": return "#FF5733";
            case "di chuyển": return "#33FF57";
            case "nhà cửa": return "#3357FF";
            case "mua sắm": return "#FF33A8";
            case "giải trí": return "#A833FF";
            case "y tế": return "#FF3333";
            case "giáo dục": return "#33FFF5";
            default:
                int hash = categoryName.hashCode();
                int r = (hash & 0xFF0000) >> 16;
                int g = (hash & 0x00FF00) >> 8;
                int b = hash & 0x0000FF;
                return String.format("#%02x%02x%02x", r, g, b);
        }
    }
}
