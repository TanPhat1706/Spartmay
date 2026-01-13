package com.mobileapp.spartmay.Wallet;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class WalletResponse {
    private Long id;
    private String name;
    private Double balance;
    private Wallet.WalletType type;
    private boolean includeInTotal;
}