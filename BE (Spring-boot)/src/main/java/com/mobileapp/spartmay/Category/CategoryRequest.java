package com.mobileapp.spartmay.Category;

import lombok.Data;

@Data
public class CategoryRequest {
    private String name;
    private String icon;
    private Category.CategoryType type;
}
