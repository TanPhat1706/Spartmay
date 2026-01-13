package com.mobileapp.spartmay.Category;

import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.mobileapp.spartmay.Transaction.TransactionRepository;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CategoryService {
    private final CategoryRepository categoryRepository;
    private final TransactionRepository transactionRepository;

    public List<Category> getAllCategories() {
        return categoryRepository.findAll();
    }

    @Transactional
    public Category createCategory(CategoryRequest request) {
        if (categoryRepository.existsByName(request.getName())) {
            throw new RuntimeException("Danh mục đã tồn tại");
        }

        Category category = Category.builder()
                .name(request.getName())
                .icon(request.getIcon())
                .type(request.getType())
                .build();
        return categoryRepository.save(category);
    }

    @Transactional
    public Category updateCategory(Long id, CategoryRequest request) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Danh mục không tồn tại"));

        category.setName(request.getName());
        category.setIcon(request.getIcon());

        return categoryRepository.save(category);
    }

    @Transactional
    public void deleteCategory(Long id) {
        if (!categoryRepository.existsById(id)) {
            throw new RuntimeException("Danh mục không tồn tại");
        }

        Boolean isInUse = transactionRepository.existsByCategoryId(id);
        if (isInUse) {
            throw new RuntimeException("Danh mục đang được sử dụng");
        }

        categoryRepository.deleteById(id);
    }
}
