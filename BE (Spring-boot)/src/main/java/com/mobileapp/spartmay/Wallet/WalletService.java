package com.mobileapp.spartmay.Wallet;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.mobileapp.spartmay.User.User;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class WalletService {
    private final WalletRepository walletRepository;

    @Transactional
    public WalletResponse createWallet(WalletRequest request, User user) {
        if (walletRepository.existsByNameAndUser(request.getName(), user)) {
            throw new RuntimeException("Ví tên '" + request.getName() + "' đã tồn tại!");
        }

        Wallet wallet = Wallet.builder()
                .name(request.getName())
                .balance(request.getBalance())
                .type(request.getType())
                .includeInTotal(request.isIncludeInTotal())
                .user(user)
                .build();

        Wallet savedWallet = walletRepository.save(wallet);
        return mapToResponse(savedWallet);
    }

    @Transactional
    public WalletResponse updateWallet(Long id, WalletRequest request, User user) {
        Wallet wallet = walletRepository.findByIdAndUser(id, user)
                .orElseThrow(() -> new RuntimeException("Ví không tìm thấy hoặc bạn không có quyền truy cập"));

        if (request.getName() != null) wallet.setName(request.getName());
        if (request.getBalance() != null) wallet.setBalance(request.getBalance());
        if (request.getType() != null) wallet.setType(request.getType());
        if (request.isIncludeInTotal() != wallet.isIncludeInTotal()) wallet.setIncludeInTotal(request.isIncludeInTotal());

        Wallet updatedWallet = walletRepository.save(wallet);
        return mapToResponse(updatedWallet);
    }

    @Transactional
    public void deleteWallet(Long id, User user) {
        Wallet wallet = walletRepository.findByIdAndUser(id, user)
                .orElseThrow(() -> new RuntimeException("Ví không tìm thấy hoặc bạn không có quyền truy cập"));

        walletRepository.delete(wallet);
    }

    private WalletResponse mapToResponse(Wallet wallet) {
        return WalletResponse.builder()
                .id(wallet.getId())
                .name(wallet.getName())
                .balance(wallet.getBalance())
                .type(wallet.getType())
                .includeInTotal(wallet.isIncludeInTotal())
                .build();
    }
}
