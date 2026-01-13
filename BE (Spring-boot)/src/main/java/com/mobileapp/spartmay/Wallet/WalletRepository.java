package com.mobileapp.spartmay.Wallet;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.mobileapp.spartmay.User.User;

@Repository
public interface WalletRepository extends JpaRepository<Wallet, Long> {
    List<Wallet> findAllByUser(User user);

    Optional<Wallet> findByIdAndUser(Long id, User user);

    boolean existsByNameAndUser(String name, User user);

    @Query("SELECT SUM(w.balance) FROM Wallet w WHERE w.user = :user AND w.includeInTotal = true")
    Double sumBalanceByUser(User user);
}
