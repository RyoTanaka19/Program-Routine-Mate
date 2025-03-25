class OpenAiService
  def self.fetch_proposal(question)
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    prompt = <<~PROMPT
      あなたはプログラミング初心者に役立つ優秀なプログラミングアシスタントです。ユーザーの質問に対して、日本語で明確かつ簡潔にプログラミングの習慣化を助けるアドバイスを提供してください。300字以内で書いてください。リストや重要なポイントを箇条書きで改行してください。各ポイントには具体例や説明を加えてください。記号やマークダウン形式（**など）は使用しないでください。

      質問: #{question}

      アドバイス:
    PROMPT

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: "あなたはプログラミング初心者に役立つ優秀なプログラミングアシスタントです。" },
          { role: "user", content: prompt }
        ],
        max_tokens: 500,
        temperature: 0.7
      }
    )

    response.dig("choices", 0, "message", "content").strip
  rescue StandardError => e
    Rails.logger.error("OpenAI APIエラー: #{e.message}")
    "現在AIからアドバイスを受けることができません。後ほどお試しください。"
  end
end
