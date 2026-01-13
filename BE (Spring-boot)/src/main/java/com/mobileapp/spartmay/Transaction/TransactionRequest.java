package com.mobileapp.spartmay.Transaction;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class TransactionRequest {
    private Double amount;
    private String note;
    private Long categoryId;
    private Long walletId;
    private LocalDateTime date;
}
