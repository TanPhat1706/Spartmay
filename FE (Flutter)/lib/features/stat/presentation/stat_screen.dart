import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spartmay/core/constants/color_constants.dart';
import 'package:spartmay/core/utils/icon_utils.dart';
import 'package:spartmay/features/stat/logic/stat_provider.dart';

class StatScreen extends StatefulWidget {
  const StatScreen({super.key});

  @override
  State<StatScreen> createState() => _StatScreenState();
}

class _StatScreenState extends State<StatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final type = _tabController.index == 0 ? 'EXPENSE' : 'INCOME';
        context.read<StatProvider>().setTransactionType(type);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatProvider>().fetchStat();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.backgroundLight,
      appBar: AppBar(
        title: const Text("Thống kê chi tiêu", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: ColorPalette.primaryGreen,
          unselectedLabelColor: Colors.grey,
          indicatorColor: ColorPalette.primaryGreen,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Chi tiêu"),
            Tab(text: "Thu nhập"),
          ],
          // Xử lý khi bấm (Tap)
          onTap: (index) {
             final type = index == 0 ? 'EXPENSE' : 'INCOME';
             context.read<StatProvider>().setTransactionType(type);
          },
        ),
      ),
      body: Consumer<StatProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildMonthSelector(provider),
              const SizedBox(height: 20),

              if (provider.isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (provider.stats.isEmpty)
                const Expanded(child: Center(child: Text("Không có dữ liệu chi tiêu")))
              else ...[
                Expanded(
                  flex: 2,
                  child: _buildPieChart(provider),
                ),

                Expanded(
                  flex: 2,
                  child: _buildDetailsList(provider),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector(StatProvider provider) {
    final dateFormat = DateFormat("MM/yyyy");
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => provider.changeMonth(-1),
          ),
          Column(
            children: [
              const Text("Thời gian", style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(
                dateFormat.format(provider.selectedDate),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColorPalette.primaryGreen),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            onPressed: () => provider.changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(StatProvider provider) {
      return Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    provider.touchSection(-1);
                    return;
                  }
                  provider.touchSection(pieTouchResponse.touchedSection!.touchedSectionIndex);
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2, // Khoảng cách giữa các miếng
              centerSpaceRadius: 40, // Độ rỗng ở giữa (Donut chart)
              sections: _showingSections(provider),
            ),
          ),
          // Text ở giữa biểu đồ (Hiển thị tổng hoặc category đang chọn)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.currentType == 'EXPENSE' ? "Tổng chi" : "Tổng thu", 
                style: const TextStyle(fontSize: 12, color: Colors.grey)
              ),
              Text(
                NumberFormat.compact().format(provider.totalExpense),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )
            ],
          )
        ],
      );
    }

  // Logic vẽ từng miếng bánh
  List<PieChartSectionData> _showingSections(StatProvider provider) {
    return List.generate(provider.stats.length, (i) {
      final isTouched = i == provider.touchedIndex;
      final stat = provider.stats[i];
      
      // Hiệu ứng phóng to khi chạm
      final fontSize = isTouched ? 18.0 : 12.0;
      final radius = isTouched ? 100.0 : 80.0; // Bán kính miếng bánh
      
      final percent = (stat.amount / provider.totalExpense) * 100;

      return PieChartSectionData(
        color: stat.color,
        value: stat.amount,
        title: '${percent.toStringAsFixed(1)}%', // Hiển thị % trên miếng bánh
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
        badgeWidget: isTouched ? _buildBadge(stat.icon) : null, // Hiện icon khi chạm
        badgePositionPercentageOffset: .98,
      );
    });
  }

  // Widget Icon nổi lên khi chạm
  Widget _buildBadge(String iconName) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 4)]),
      child: Icon(IconUtils.getIconByName(iconName), size: 20, color: ColorPalette.primaryGreen),
    );
  }

  // 3. Danh sách chi tiết bên dưới
  Widget _buildDetailsList(StatProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: provider.stats.length,
      itemBuilder: (context, index) {
        final stat = provider.stats[index];
        final isTouched = index == provider.touchedIndex;
        
        return GestureDetector(
          onTap: () => provider.touchSection(index), // Bấm vào list cũng highlight chart
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isTouched ? Colors.grey.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: isTouched ? Border.all(color: stat.color, width: 2) : null,
            ),
            child: Row(
              children: [
                // Ô màu
                Container(width: 16, height: 16, decoration: BoxDecoration(color: stat.color, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                
                // Tên category
                Text(stat.categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                
                // Số tiền
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(stat.amount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${((stat.amount / provider.totalExpense) * 100).toStringAsFixed(1)}%",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}