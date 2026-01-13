// package com.mobileapp.spartmay.Dashboard;

// import org.springframework.http.ResponseEntity;
// import org.springframework.security.core.annotation.AuthenticationPrincipal;
// import org.springframework.web.bind.annotation.GetMapping;
// import org.springframework.web.bind.annotation.RequestMapping;
// import org.springframework.web.bind.annotation.RestController;
// import com.mobileapp.spartmay.User.User;
// import lombok.RequiredArgsConstructor;

// @RestController
// @RequestMapping("/api/dashboard")
// @RequiredArgsConstructor
// public class DashboardController {
//     private final DashboardService dashboardService;

//     @GetMapping
//     public ResponseEntity<DashboardResponse> getDashboard(@AuthenticationPrincipal User user) {
//         return ResponseEntity.ok(dashboardService.getDashboardData(user));
//     }
// }
