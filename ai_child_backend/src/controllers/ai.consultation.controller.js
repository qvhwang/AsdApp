const axios = require('axios');
const db = require('../config/db');

const GROQ_URL = 'https://api.groq.com/openai/v1/chat/completions';
const GROQ_MODEL = 'llama-3.1-8b-instant';


exports.askAI = async (req, res) => {
  const { user_id, child_id, question } = req.body;

  if (!user_id || !child_id || !question) {
    return res.status(400).json({ message: 'Thiếu dữ liệu' });
  }

  try {
    const [childRows] = await db.execute(
      'SELECT full_name, birth_date, gender, guardian_name FROM children WHERE id = ? AND user_id = ?',
      [child_id, user_id]
    );

    if (childRows.length === 0) {
      return res.status(404).json({ message: 'Không tìm thấy hồ sơ trẻ' });
    }

    const child = childRows[0];
    const age = _calcAge(child.birth_date);
    const gender = child.gender === 'MALE' ? 'bé trai' : 'bé gái';
    const dob = child.birth_date
      ? new Date(child.birth_date).toLocaleDateString('vi-VN')
      : 'không rõ';
    const guardian = child.guardian_name || 'không rõ';

    const [history] = await db.execute(
      `SELECT question, ai_response FROM ai_consultations
       WHERE child_id = ? ORDER BY created_at DESC LIMIT 5`,
      [child_id]
    );

    const [sessions] = await db.execute(
      `SELECT id, risk_level, total_score, created_at
       FROM mchat_sessions
       WHERE child_id = ?
       ORDER BY created_at DESC LIMIT 3`,
      [child_id]
    );

    let screeningContext = '';
    if (sessions.length > 0) {
      const latestSession = sessions[0];
      const [answers] = await db.execute(
        `SELECT q.question_text, a.answer, q.risk_answer
         FROM mchat_answers a
         JOIN mchat_questions q ON a.question_id = q.id
         WHERE a.session_id = ?`,
        [latestSession.id]
      );

      const riskLabel = {
        Low: 'Nguy cơ thấp',
        Medium: 'Nguy cơ trung bình',
        High: 'Nguy cơ cao',
      };

      screeningContext = `
KẾT QUẢ SÀNG LỌC M-CHAT GẦN NHẤT (${new Date(latestSession.created_at).toLocaleDateString('vi-VN')}):
- Mức nguy cơ: ${riskLabel[latestSession.risk_level] || latestSession.risk_level}
- Điểm số: ${latestSession.total_score}/20
${answers.length > 0 ? `- Các câu trả lời đáng chú ý:
${answers
  .filter(a => a.answer === a.risk_answer)
  .slice(0, 5)
  .map(a => `  • ${a.question_text}: ${a.answer === 'YES' ? 'Có' : 'Không'} (câu trả lời nguy cơ)`)
  .join('\n')}` : ''}
${sessions.length > 1 ? `- Đã thực hiện ${sessions.length} lần sàng lọc` : ''}`;
    }

    const [mchatQuestions] = await db.execute(
      `SELECT question_text, risk_answer FROM mchat_questions
       WHERE is_active = 1 ORDER BY id ASC`
    );

    const questionsLibrary = mchatQuestions.length > 0
      ? '\nTHƯ VIỆN 20 CÂU HỎI M-CHAT-R/F:\n' +
        mchatQuestions.map((q, i) =>
          (i + 1) + '. ' + q.question_text + ' (đáp án nguy cơ: ' + (q.risk_answer === 'YES' ? 'Có' : 'Không') + ')'
        ).join('\n')
      : '';

    const systemPrompt = `Bạn là chuyên gia tư vấn phát triển trẻ em, chuyên về rối loạn phổ tự kỷ (ASD).
Bạn đang tư vấn cho phụ huynh về ${gender} tên ${child.full_name}, ${age}.
- Ngày sinh: ${dob}
- Người bảo hộ: ${guardian}
${screeningContext ? screeningContext : 'Trẻ chưa có kết quả sàng lọc M-CHAT.'}
${questionsLibrary}
Hãy trả lời bằng tiếng Việt, thân thiện, dễ hiểu, ngắn gọn (tối đa 300 từ).
Dựa vào kết quả sàng lọc và thư viện câu hỏi M-CHAT để giải thích và tư vấn chi tiết.
Khi phụ huynh hỏi về từng câu hỏi cụ thể, hãy giải thích ý nghĩa của câu hỏi đó.
Luôn nhắc phụ huynh tham khảo ý kiến bác sĩ chuyên khoa cho các vấn đề nghiêm trọng.
KHÔNG chẩn đoán bệnh, chỉ cung cấp thông tin hỗ trợ và hướng dẫn chung.`;

    const reversedHistory = history.reverse();

    const chatMessages = [
      { role: 'system', content: systemPrompt },
    ];

    for (const h of reversedHistory) {
      chatMessages.push({ role: 'user', content: h.question });
      chatMessages.push({ role: 'assistant', content: h.ai_response });
    }

    chatMessages.push({ role: 'user', content: question });

    console.log(`🤖 Gọi Groq model: ${GROQ_MODEL}`);
    const groqRes = await axios.post(
      GROQ_URL,
      {
        model: GROQ_MODEL,
        messages: chatMessages,
        max_tokens: 512,
        temperature: 0.7,
      },
      {
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${process.env.GROQ_API_KEY}`,
        },
        timeout: 30000,
      }
    );

    let aiResponse = groqRes.data?.choices?.[0]?.message?.content?.trim();

    if (!aiResponse) {
      return res.status(500).json({ message: 'AI không phản hồi' });
    }

    await db.execute(
      `INSERT INTO ai_consultations (user_id, child_id, question, ai_response)
       VALUES (?, ?, ?, ?)`,
      [user_id, child_id, question, aiResponse]
    );

    res.json({ response: aiResponse });
  } catch (err) {
    console.error('AI Error:', err.response?.data || err.message);

    if (err.response?.status === 401) {
      return res.status(500).json({ message: 'HuggingFace API key không hợp lệ' });
    }
    if (err.response?.status === 503 || err.code === 'ECONNABORTED') {
      return res.status(503).json({ message: 'Model AI đang khởi động, vui lòng thử lại sau 20 giây' });
    }
    if (err.response?.status === 429) {
      return res.status(429).json({ message: 'AI đang bận, vui lòng thử lại sau' });
    }

    res.status(500).json({ message: 'Lỗi kết nối AI: ' + err.message });
  }
};

exports.getHistoryByChild = async (req, res) => {
  const { childId } = req.params;
  try {
    const [rows] = await db.execute(
      `SELECT id, question, ai_response, created_at
       FROM ai_consultations
       WHERE child_id = ?
       ORDER BY created_at ASC`,
      [childId]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.getHistoryByUser = async (req, res) => {
  const { userId } = req.params;
  try {
    const [rows] = await db.execute(
      `SELECT ac.id, ac.question, ac.ai_response, ac.created_at,
              c.full_name AS child_name
       FROM ai_consultations ac
       JOIN children c ON ac.child_id = c.id
       WHERE ac.user_id = ?
       ORDER BY ac.created_at DESC`,
      [userId]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.deleteHistory = async (req, res) => {
  const { id } = req.params;
  try {
    await db.execute(
      'DELETE FROM ai_consultations WHERE id = ? AND user_id = ?',
      [id, req.user.id]
    );
    res.json({ message: 'Đã xóa' });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server' });
  }
};

function _calcAge(dob) {
  if (!dob) return 'không rõ tuổi';
  const birth = new Date(dob);
  const now = new Date();
  const months =
    (now.getFullYear() - birth.getFullYear()) * 12 +
    (now.getMonth() - birth.getMonth());

  if (months < 12) return `${months} tháng tuổi`;
  const years = Math.floor(months / 12);
  const remainMonths = months % 12;
  return remainMonths > 0
    ? `${years} tuổi ${remainMonths} tháng`
    : `${years} tuổi`;
}