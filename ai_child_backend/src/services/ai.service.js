const axios = require('axios');

exports.askQwen = async (question) => {
  const hfResponse = await axios.post(
    'https://api-inference.huggingface.co/models/Qwen/Qwen2.5-Coder-32B-Instruct',
    {
      inputs: `<|im_start|>system
Bạn là chuyên gia tư vấn về rối loạn phổ tự kỷ (ASD) ở trẻ em...
<|im_end|>
<|im_start|>user
${question}<|im_end|>
<|im_start|>assistant`,
      parameters: {
        max_new_tokens: 400,
        temperature: 0.7,
        top_p: 0.9,
      },
      options: { wait_for_model: true }
    },
    {
      headers: {
        Authorization: `Bearer ${process.env.HF_API_KEY}`,
      },
      timeout: 120000,
    }
  );

  const data = hfResponse.data;

  if (Array.isArray(data) && data[0]?.generated_text) {
    return data[0].generated_text.trim();
  }

  if (data.generated_text) {
    return data.generated_text.trim();
  }

  throw new Error('Không nhận được phản hồi từ AI');
};