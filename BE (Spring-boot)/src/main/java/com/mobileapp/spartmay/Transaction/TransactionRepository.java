package com.mobileapp.spartmay.Transaction;

import java.time.LocalDateTime;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import com.mobileapp.spartmay.Category.Category;
import com.mobileapp.spartmay.Stat.MonthlyStatResponse;
import com.mobileapp.spartmay.User.User;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    Page<Transaction> findAllByUserOrderByDateDesc(User user, Pageable pageable);

    @Query("SELECT SUM(t.amount) FROM Transaction t WHERE t.user = ?1 AND t.category.type = 'INCOME'")
    Double sumIncomeByUser(User user);

    @Query("SELECT SUM(t.amount) FROM Transaction t WHERE t.user = ?1 AND t.category.type = 'EXPENSE'")
    Double sumExpenseByUser(User user);

    List<Transaction> findByUserAndDateBetween(User user, LocalDateTime start, LocalDateTime end);

    Page<Transaction> findByUserAndDateBetween(
        User user, 
        LocalDateTime start, 
        LocalDateTime end, 
        Pageable pageable
    );

    Boolean existsByCategoryId(Long categoryId);

    @Query("SELECT new com.mobileapp.spartmay.Stat.MonthlyStatResponse(" +
           "c.name, c.icon, SUM(t.amount)) " +
           "FROM Transaction t " +
           "JOIN t.category c " +
           "WHERE t.user = :user " +
           "AND t.date BETWEEN :startDate AND :endDate " +
           "AND c.type = :type " +
           "GROUP BY c.name, c.icon")
    List<MonthlyStatResponse> getMonthlyStatsByType(
            @Param("user") User user,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate,
            @Param("type") Category.CategoryType type
    );
}
