package com.mobileapp.spartmay.Transaction;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.mobileapp.spartmay.Stat.MonthlyStatResponse;
import com.mobileapp.spartmay.User.User;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/transactions")
@RequiredArgsConstructor
public class TransactionController {
    private final TransactionService transactionService;

    @PostMapping
    public ResponseEntity<?> createTransaction(@RequestBody TransactionRequest request, @AuthenticationPrincipal User user) {
        transactionService.createTransaction(request, user);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Tạo giao dịch thành công");
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateTransaction(@PathVariable Long id, @RequestBody TransactionRequest request, @AuthenticationPrincipal User user) {
        return ResponseEntity.ok(transactionService.updateTransaction(id, request, user));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteTransaction(@PathVariable Long id, @AuthenticationPrincipal User user) {
        System.out.println("id: " + id);
        System.out.println("user: " + user);
        transactionService.deleteTransaction(id, user);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Xóa giao dịch thành công");
        return ResponseEntity.ok(response);
    }

    @GetMapping
    public ResponseEntity<Page<Transaction>> getTransactions(
            @AuthenticationPrincipal User user,
            @RequestParam(required = false) LocalDate date,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        Page<Transaction> transactionPage = transactionService.getTransactions(user, date, page, size);
        return ResponseEntity.ok(transactionPage);
    }

    @GetMapping("/monthly-summary")
    public ResponseEntity<MonthlySummaryResponse> getMonthlySummary(
            @AuthenticationPrincipal User user,
            @RequestParam int month,
            @RequestParam int year
    ) {
        return ResponseEntity.ok(transactionService.getMonthlySummary(user, month, year));
    }

    @GetMapping("/monthly-stats")
    public ResponseEntity<List<MonthlyStatResponse>> getMonthlyStats(
        @AuthenticationPrincipal User user,
        @RequestParam int month,
        @RequestParam int year,
        @RequestParam(defaultValue = "EXPENSE") String type
    ) {
        return ResponseEntity.ok(transactionService.getStatistics(user, month, year, type));
    }
}
