import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F6),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Hướng dẫn sử dụng'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange.shade700,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lưu ý quan trọng',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.deepOrange,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Ứng dụng này chỉ là công cụ hỗ trợ sàng lọc ban đầu, KHÔNG thay thế chẩn đoán y tế. Kết quả sàng lọc không phải kết luận chính thức. Hãy đưa trẻ đến gặp bác sĩ chuyên khoa nếu có nghi ngờ.',
                          style: TextStyle(fontSize: 13, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _section(
              icon: Icons.info_outline,
              color: Colors.teal,
              title: 'Tổng quan ứng dụng',
              content:
                  'Ứng dụng hỗ trợ sàng lọc rối loạn phổ tự kỷ (ASD) ở trẻ nhỏ dựa trên bộ công cụ M-CHAT-R/F (Modified Checklist for Autism in Toddlers). '
                  'Đây là bộ câu hỏi được sử dụng rộng rãi trên thế giới để phát hiện sớm các dấu hiệu tự kỷ ở trẻ từ 16–30 tháng tuổi.',
            ),

            const SizedBox(height: 12),

            _section(
              icon: Icons.list_alt,
              color: Colors.blue,
              title: 'Cách sử dụng',
              steps: [
                'Tạo hồ sơ trẻ với đầy đủ thông tin (tên, ngày sinh, giới tính)',
                'Chọn "M-CHAT-R/F" từ màn hình chính',
                'Chọn hồ sơ trẻ cần sàng lọc',
                'Trả lời lần lượt tất cả câu hỏi dựa trên quan sát thực tế',
                'Xem kết quả và mức nguy cơ sau khi hoàn thành',
              ],
            ),

            const SizedBox(height: 12),

            _section(
              icon: Icons.calculate_outlined,
              color: Colors.purple,
              title: 'Cách tính điểm M-CHAT',
              content:
                  'Mỗi câu hỏi có đáp án "Có" hoặc "Không". Mỗi câu trả lời được xác định là có nguy cơ (risk answer) sẽ được tính 1 điểm. Tổng điểm là tổng số câu trả lời có nguy cơ.',
            ),

            const SizedBox(height: 12),

            _riskSection(),

            const SizedBox(height: 12),

            _section(
              icon: Icons.lightbulb_outline,
              color: Colors.orange,
              title: 'Lưu ý khi thực hiện',
              steps: [
                'Trả lời dựa trên hành vi thường ngày của trẻ, không phải ngày hôm nay',
                'Nếu trẻ chưa từng có cơ hội thực hiện hành vi, hãy ước đoán phản ứng của trẻ',
                'Không để người khác ảnh hưởng đến câu trả lời của bạn',
                'Kết quả nguy cơ thấp không có nghĩa là hoàn toàn bình thường',
                'Kết quả nguy cơ cao không có nghĩa là trẻ bị tự kỷ',
              ],
            ),

            const SizedBox(height: 12),

            _section(
              icon: Icons.smart_toy_outlined,
              color: Colors.indigo,
              title: 'Tính năng Tư vấn AI',
              content:
                  'Chức năng "Tư vấn AI" cho phép bạn đặt câu hỏi về sự phát triển của trẻ và nhận tư vấn sơ bộ. '
                  'AI được hỗ trợ bởi công nghệ tiên tiến nhưng KHÔNG thay thế ý kiến bác sĩ chuyên khoa.',
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Đã hiểu'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required Color color,
    required String title,
    String? content,
    List<String>? steps,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (content != null)
            Text(content, style: const TextStyle(fontSize: 13, height: 1.6)),
          if (steps != null)
            ...steps.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: color.withOpacity(0.15),
                      child: Text(
                        '${e.key + 1}',
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.value,
                        style: const TextStyle(fontSize: 13, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _riskSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.red.withOpacity(0.15),
                child: const Icon(Icons.bar_chart, size: 18, color: Colors.red),
              ),
              const SizedBox(width: 10),
              const Text(
                'Mức nguy cơ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _riskRow(
            'Nguy cơ thấp',
            '0–2 điểm',
            Colors.green,
            'Tiếp tục theo dõi sự phát triển bình thường',
          ),
          const SizedBox(height: 8),
          _riskRow(
            'Nguy cơ trung bình',
            '3–7 điểm',
            Colors.orange,
            'Nên tham khảo ý kiến bác sĩ nhi khoa',
          ),
          const SizedBox(height: 8),
          _riskRow(
            'Nguy cơ cao',
            '8+ điểm',
            Colors.red,
            'Cần đưa trẻ đến chuyên gia càng sớm càng tốt',
          ),
        ],
      ),
    );
  }

  Widget _riskRow(String label, String score, Color color, String advice) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        score,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  advice,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
