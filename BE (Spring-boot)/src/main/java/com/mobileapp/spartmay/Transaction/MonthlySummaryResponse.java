package com.mobileapp.spartmay.Transaction;

import java.time.LocalDate;
import java.util.List;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class MonthlySummaryResponse {
    private Double totalIncome;
    private Double totalExpense;
    private List<DailyStat> dailyStats;

    @Data
    @Builder
    public static class DailyStat {
        private LocalDate date;
        private Double income;
        private Double expense;
    }
}
