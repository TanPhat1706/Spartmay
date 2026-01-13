package com.mobileapp.spartmay.Wallet;

import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.mobileapp.spartmay.User.User;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/wallets")
@RequiredArgsConstructor
public class WalletController {
    private final WalletRepository walletRepository;
    private final WalletService walletService;

    @PostMapping
    public ResponseEntity<WalletResponse> createWallet(
        @RequestBody WalletRequest request,
        @AuthenticationPrincipal User user) {
            System.out.println("Received wallet creation request: " + request);
            System.out.println("Authenticated user: " + user);
            return ResponseEntity.ok(walletService.createWallet(request, user));
    }

    @PutMapping("/{id}")
    public ResponseEntity<WalletResponse> updateWallet(
        @PathVariable Long id,
        @RequestBody WalletRequest request,
        @AuthenticationPrincipal User user) {
            System.out.println("Received wallet update request for ID " + id + ": " + request);
            return ResponseEntity.ok(walletService.updateWallet(id, request, user));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteWallet(
        @PathVariable Long id,
        @AuthenticationPrincipal User user) {
            walletService.deleteWallet(id, user);
            return ResponseEntity.ok("Xóa ví thành công");
    }

    @GetMapping
    public ResponseEntity<List<Wallet>> getMyWallets(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(walletRepository.findAllByUser(user));
    }

    @GetMapping("/total-balance")
    public ResponseEntity<Double> getTotalBalance(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(walletRepository.sumBalanceByUser(user));
    }
}