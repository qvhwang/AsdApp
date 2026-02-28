import 'dart:io';

import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/stats_controller.dart';
import '../../models/stats_model.dart';

class AdminScreeningStatsScreen extends StatefulWidget {
  const AdminScreeningStatsScreen({super.key});

  @override
  State<AdminScreeningStatsScreen> createState() =>
      _AdminScreeningStatsScreenState();
}

class _AdminScreeningStatsScreenState extends State<AdminScreeningStatsScreen> {
  final StatsController _controller = StatsController();

  ScreeningStats? _stats;
  bool _loading = false;
  bool _hasError = false;
  DateTime? _fromDate;
  DateTime? _toDate;
  String _chartType = 'pie';

  final _dateFmt = DateFormat('dd/MM/yyyy');
  final _apiFmt = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      final data = await _controller.getScreeningStats(
        from: _fromDate != null ? _apiFmt.format(_fromDate!) : null,
        to: _toDate != null ? _apiFmt.format(_toDate!) : null,
      );
      if (mounted) {
        setState(() {
          _stats = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _pickDate(bool isFrom) async {
    final initial = isFrom
        ? (_fromDate ?? DateTime.now())
        : (_toDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;

    setState(() {
      if (isFrom) {
        _fromDate = picked;
        if (_toDate != null && _toDate!.isBefore(picked)) {
          _toDate = null;
        }
      } else {
        _toDate = picked;
        if (_fromDate != null && _fromDate!.isAfter(picked)) {
          _fromDate = null;
        }
      }
    });

    await _load();
  }

  void _clearDates() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
    _load();
  }

  Future<void> _exportCSV() async {
    if (_stats == null || _stats!.details.isEmpty) {
      _showSnack('Không có dữ liệu để xuất');
      return;
    }
    try {
      final rows = [
        ['STT', 'Phụ huynh', 'Tên trẻ', 'Mức nguy cơ', 'Điểm', 'Ngày'],
        ..._stats!.details.asMap().entries.map(
          (e) => [
            e.key + 1,
            e.value.userName,
            e.value.childName,
            e.value.riskLevel,
            e.value.totalScore,
            _formatDate(e.value.createdAt),
          ],
        ),
      ];
      final csv = const ListToCsvConverter().convert(rows);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/thong_ke_sang_loc.csv');
      await file.writeAsString(csv);
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Thống kê kết quả sàng lọc M-CHAT');
    } catch (e) {
      _showSnack('Xuất báo cáo không thành công, vui lòng thử lại');
    }
  }

  String _formatDate(String raw) {
    try {
      return _dateFmt.format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return raw;
    }
  }

  String _riskLabel(String level) {
    switch (level) {
      case 'High':
        return 'Nguy cơ cao';
      case 'Medium':
        return 'Nguy cơ TB';
      default:
        return 'Nguy cơ thấp';
    }
  }

  Color _riskColor(String level) {
    switch (level) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String get _rangeLabel {
    if (_fromDate == null && _toDate == null) return 'Tất cả thời gian';
    if (_fromDate != null && _toDate == null)
      return 'Từ ${_dateFmt.format(_fromDate!)} trở đi';
    if (_fromDate == null && _toDate != null)
      return 'Đến ${_dateFmt.format(_toDate!)}';
    return '${_dateFmt.format(_fromDate!)} – ${_dateFmt.format(_toDate!)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F6),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Thống kê sàng lọc'),
        actions: [
          if (_stats != null && _stats!.details.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Xuất CSV',
              onPressed: _exportCSV,
            ),
          // ✅ Refresh gọi _load() trực tiếp
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
          ? _buildError()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateFilter(),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _rangeLabel,
                      style: TextStyle(
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryCards(),
                  const SizedBox(height: 16),
                  // ✅ Nếu total = 0 thì báo không có dữ liệu
                  if (_stats == null || _stats!.summary.total == 0)
                    _buildEmpty()
                  else ...[
                    _buildChartToggle(),
                    const SizedBox(height: 12),
                    _chartType == 'pie' ? _buildPieChart() : _buildBarChart(),
                    const SizedBox(height: 16),
                    _buildDetailTable(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildDateFilter() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Khoảng thời gian',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _fromDate != null ? _dateFmt.format(_fromDate!) : 'Từ ngày',
                    style: const TextStyle(fontSize: 13),
                  ),
                  onPressed: () => _pickDate(true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _toDate != null ? _dateFmt.format(_toDate!) : 'Đến ngày',
                    style: const TextStyle(fontSize: 13),
                  ),
                  onPressed: () => _pickDate(false),
                ),
              ),
              if (_fromDate != null || _toDate != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: _clearDates,
                  tooltip: 'Xóa bộ lọc',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final s = _stats?.summary;
    return Row(
      children: [
        _summaryCard('Tổng', s?.total ?? 0, Colors.teal),
        const SizedBox(width: 8),
        _summaryCard('Cao', s?.high ?? 0, Colors.red),
        const SizedBox(width: 8),
        _summaryCard('TB', s?.medium ?? 0, Colors.orange),
        const SizedBox(width: 8),
        _summaryCard('Thấp', s?.low ?? 0, Colors.green),
      ],
    );
  }

  Widget _summaryCard(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartToggle() {
    return Row(
      children: [
        const Text('Biểu đồ:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 12),
        ChoiceChip(
          label: const Text('Tròn'),
          selected: _chartType == 'pie',
          onSelected: (_) => setState(() => _chartType = 'pie'),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Cột'),
          selected: _chartType == 'bar',
          onSelected: (_) => setState(() => _chartType = 'bar'),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    final s = _stats!.summary;
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  if (s.high > 0)
                    PieChartSectionData(
                      value: s.high.toDouble(),
                      color: Colors.red,
                      title: '${(s.high / s.total * 100).toStringAsFixed(0)}%',
                      radius: 70,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (s.medium > 0)
                    PieChartSectionData(
                      value: s.medium.toDouble(),
                      color: Colors.orange,
                      title:
                          '${(s.medium / s.total * 100).toStringAsFixed(0)}%',
                      radius: 70,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (s.low > 0)
                    PieChartSectionData(
                      value: s.low.toDouble(),
                      color: Colors.green,
                      title: '${(s.low / s.total * 100).toStringAsFixed(0)}%',
                      radius: 70,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 0,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _legend('Nguy cơ cao', Colors.red, s.high),
              const SizedBox(height: 8),
              _legend('Nguy cơ TB', Colors.orange, s.medium),
              const SizedBox(height: 8),
              _legend('Nguy cơ thấp', Colors.green, s.low),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(String label, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text('$label: $value', style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildBarChart() {
    final s = _stats!.summary;
    final maxY =
        [s.high, s.medium, s.low].reduce((a, b) => a > b ? a : b).toDouble() +
        2;

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barGroups: [
            _barGroup(0, s.high.toDouble(), Colors.red),
            _barGroup(1, s.medium.toDouble(), Colors.orange),
            _barGroup(2, s.low.toDouble(), Colors.green),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  const labels = ['Cao', 'TB', 'Thấp'];
                  return Text(
                    labels[v.toInt()],
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 28),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 40,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildDetailTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(14),
            child: Text(
              'Chi tiết',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          const Divider(height: 1),
          ..._stats!.details.map(
            (d) => ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: _riskColor(d.riskLevel).withOpacity(0.15),
                child: Text(
                  d.riskLevel == 'High'
                      ? 'C'
                      : d.riskLevel == 'Medium'
                      ? 'T'
                      : 'A',
                  style: TextStyle(
                    color: _riskColor(d.riskLevel),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              title: Text(
                '${d.userName} → ${d.childName}',
                style: const TextStyle(fontSize: 13),
              ),
              subtitle: Text(
                '${_riskLabel(d.riskLevel)} • Điểm: ${d.totalScore}',
                style: TextStyle(fontSize: 12, color: _riskColor(d.riskLevel)),
              ),
              trailing: Text(
                _formatDate(d.createdAt),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    final hasFilter = _fromDate != null || _toDate != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            hasFilter
                ? 'Không có dữ liệu trong khoảng thời gian đã chọn'
                : 'Không có dữ liệu để thống kê',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          if (hasFilter) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.clear),
              label: const Text('Xóa bộ lọc'),
              onPressed: _clearDates,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          const Text('Không tải được dữ liệu'),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
