package com.mobileapp.spartmay.Wallet;

import lombok.Data;

@Data
public class WalletRequest {
    private String name;
    private Double balance;
    private Wallet.WalletType type;
    private boolean includeInTotal;
}
