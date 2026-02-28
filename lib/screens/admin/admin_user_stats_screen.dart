import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/stats_controller.dart';
import '../../models/stats_model.dart';

class AdminUserStatsScreen extends StatefulWidget {
  const AdminUserStatsScreen({super.key});

  @override
  State<AdminUserStatsScreen> createState() => _AdminUserStatsScreenState();
}

class _AdminUserStatsScreenState extends State<AdminUserStatsScreen> {
  final StatsController _controller = StatsController();

  List<UserStat> _users = [];
  List<UserStat> _filtered = [];
  bool _loading = true;
  String _sort = 'count';
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _controller.getUserStats(sort: _sort);
    setState(() {
      _users = data;
      _applySearch();
      _loading = false;
    });
  }

  void _applySearch() {
    _filtered = _users
        .where(
          (u) =>
              u.fullName.toLowerCase().contains(_search.toLowerCase()) ||
              u.email.toLowerCase().contains(_search.toLowerCase()),
        )
        .toList();
  }

  String _formatRelative(String? raw) {
    if (raw == null) return 'Chưa thực hiện';
    try {
      final d = DateTime.parse(raw).toLocal();
      final diff = DateTime.now().difference(d);
      if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
      if (diff.inHours < 24) return '${diff.inHours} giờ trước';
      if (diff.inDays < 30) return '${diff.inDays} ngày trước';
      return DateFormat('dd/MM/yyyy').format(d);
    } catch (_) {
      return raw;
    }
  }

  Future<void> _exportCSV() async {
    if (_filtered.isEmpty) {
      _showSnack('Không có dữ liệu để xuất');
      return;
    }
    try {
      final rows = [
        [
          'STT',
          'Họ tên',
          'Email',
          'Số hồ sơ trẻ',
          'Số lần sàng lọc',
          'Lần gần nhất',
        ],
        ..._filtered.asMap().entries.map(
          (e) => [
            e.key + 1,
            e.value.fullName,
            e.value.email,
            e.value.totalChildren,
            e.value.totalScreenings,
            _formatRelative(e.value.lastScreening),
          ],
        ),
      ];

      final csv = const ListToCsvConverter().convert(rows);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/thong_ke_nguoi_dung.csv');
      await file.writeAsString(csv);
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Thống kê chi tiết người dùng');
    } catch (e) {
      _showSnack('Xuất báo cáo không thành công, vui lòng thử lại');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F6),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Thống kê người dùng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Xuất CSV',
            onPressed: _exportCSV,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Column(
        children: [
          // SEARCH + SORT
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) {
                    setState(() {
                      _search = v;
                      _applySearch();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên hoặc email...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text('Sắp xếp: ', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 8),
                      _sortChip('Số lần SL', 'count'),
                      const SizedBox(width: 6),
                      _sortChip('Gần nhất', 'latest'),
                      const SizedBox(width: 6),
                      _sortChip('Tên A-Z', 'name'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // STATS BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _statChip('Tổng: ${_users.length}', Colors.teal),
                const SizedBox(width: 8),
                _statChip(
                  'Đã SL: ${_users.where((u) => u.totalScreenings > 0).length}',
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _statChip(
                  'Chưa SL: ${_users.where((u) => u.totalScreenings == 0).length}',
                  Colors.grey,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // LIST
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                ? Center(
                    child: Text(
                      _users.isEmpty
                          ? 'Chưa có người dùng'
                          : 'Không tìm thấy kết quả',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _userCard(_filtered[i], i),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _sortChip(String label, String value) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: _sort == value,
      selectedColor: Colors.teal.withOpacity(0.2),
      onSelected: (_) {
        setState(() => _sort = value);
        _load();
      },
    );
  }

  Widget _statChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _userCard(UserStat user, int index) {
    final hasScreenings = user.totalScreenings > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // AVATAR
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.teal.withOpacity(0.15),
            child: Text(
              user.fullName.isNotEmpty
                  ? user.fullName.substring(0, 1).toUpperCase()
                  : '?',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    _infoChip(
                      Icons.child_care,
                      '${user.totalChildren} hồ sơ trẻ',
                      Colors.blue,
                    ),
                    _infoChip(
                      Icons.fact_check,
                      '${user.totalScreenings} lần SL',
                      hasScreenings ? Colors.teal : Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        hasScreenings
                            ? 'Gần nhất: ${_formatRelative(user.lastScreening)}'
                            : 'Chưa thực hiện lần nào',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: hasScreenings ? Colors.teal : Colors.grey,
                          fontStyle: hasScreenings
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // RANK
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '#${index + 1}',
              style: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, color: color),
        ),
      ],
    );
  }
}
