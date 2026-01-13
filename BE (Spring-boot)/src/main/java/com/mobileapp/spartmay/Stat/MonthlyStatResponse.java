package com.mobileapp.spartmay.Stat;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor @AllArgsConstructor
public class MonthlyStatResponse {
    private String categoryName;
    private String icon;
    private Double amount;
    private String colorHex;

    public MonthlyStatResponse(String categoryName, String icon, Double amount) {
        this.categoryName = categoryName;
        this.icon = icon;
        this.amount = Math.abs(amount != null ? amount : 0.0);
    }
}
