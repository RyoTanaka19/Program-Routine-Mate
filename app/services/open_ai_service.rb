class OpenAiService
  def self.generate_question(content, type: :written)
  client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

  prompt = case type
  when :written
    <<~PROMPT
      あなたはプログラミング初心者に役立つ優秀なプログラミングアシスタントです。
      学習内容と感想を元に、理解度を深めるための具体的な記述式のプログラミング問題を1つ作成してください。
      ・300字以内
      ・問題文のみを出力してください（選択肢や解説は不要です）。
      ・初心者にもわかりやすく、簡潔に作成してください。

      学習内容と感想:
      #{content}

      問題:
    PROMPT
  when :multiple_choice
    <<~PROMPT
      あなたはプログラミング初心者に役立つ優秀なプログラミングアシスタントです。
      学習内容と感想を元に、理解度を深めるためのマルチプルチョイス形式のプログラミング問題を1つ作成してください。

      - 問題文と、選択肢A〜Dを含めてください（形式例：A. 〜、B. 〜）。
      - 正解は「正解: A」のように、最後に A〜D で明示してください（選択肢の文や内容ではなくラベルで指定）。
      - 出力は問題・選択肢・正解のみとし、それ以外は出力しないでください。
      - 全体で300字以内におさめ、初心者でも理解できるようわかりやすく書いてください。

      学習内容と感想:
      #{content}

      出力形式:
      問題文
      A. ○○○
      B. ○○○
      C. ○○○
      D. ○○○
      正解: A

      問題:
    PROMPT
  else
    raise ArgumentError, "Unsupported question type: #{type}"
  end

  response = client.chat(
    parameters: {
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: "あなたは初心者向けプログラミング講師です。わかりやすく、丁寧に作成してください。" },
        { role: "user", content: prompt }
      ],
      max_tokens: 300,
      temperature: 0.7
    }
  )

  response.dig("choices", 0, "message", "content")&.strip
rescue => e
  Rails.logger.error("OpenAIエラー: #{e.message}")
  nil
end


  # 回答と問題文から正誤判定・解説を生成
  def self.explain_answer(question_text, user_answer)
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    prompt = <<~PROMPT
      以下の問題文と選択肢があります。ユーザーの回答が正しいかどうか判定し、正解・不正解の結果と理由、解説を300字以内でわかりやすく教えてください。

      問題と選択肢:
      #{question_text}

      ユーザーの回答:
      #{user_answer}

      結果と解説:
    PROMPT

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: "あなたは教育者です。正誤判定とわかりやすい解説を作成してください。" },
          { role: "user", content: prompt }
        ],
        max_tokens: 300,
        temperature: 0.7
      }
    )

    response.dig("choices", 0, "message", "content")&.strip
  rescue => e
    Rails.logger.error("OpenAIエラー: #{e.message}")
    nil
  end
end
