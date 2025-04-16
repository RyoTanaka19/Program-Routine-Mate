class OpenAiService
  # クラスメソッド: fetch_suggest
  # 質問を受け取って、OpenAI APIを使ってアドバイスを生成する
  def self.fetch_suggest(question)
    # OpenAIクライアントのインスタンスを作成。APIキーは環境変数から取得
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    # AIに送るプロンプトの作成
    # ユーザーが入力した質問をAIのプロンプトに埋め込んで、具体的なアドバイスを求める
    prompt = <<~PROMPT
      あなたはプログラミング初心者に役立つ優秀なプログラミングアシスタントです。ユーザーの質問に対して、日本語で明確かつ簡潔にプログラミングの習慣化を助けるアドバイスを提供してください。300字以内で書いてください。リストや重要なポイントを箇条書きで改行してください。各ポイントには具体例や説明を加えてください。記号やマークダウン形式（**など）は使用しないでください。

      質問: #{question}

      アドバイス:
    PROMPT

    # OpenAI APIにリクエストを送信して、返答を受け取る
    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",  # 使用するモデルを指定
        messages: [
          { role: "system", content: "あなたはプログラミング初心者に役立つ優秀なプログラミングアシスタントです。" },  # システムメッセージで役割を設定
          { role: "user", content: prompt }  # ユーザーからの質問（プロンプト）
        ],
        max_tokens: 500,  # レスポンスの最大トークン数を指定
        temperature: 0.7  # 生成されるテキストのランダム性を指定（0.7はやや創造的なレスポンス）
      }
    )

    # APIから返ってきたレスポンスの内容を抽出して返す
    # "choices" 配列の最初の要素からアドバイスの内容を取得し、余分な空白を削除
    response.dig("choices", 0, "message", "content").strip
  rescue StandardError => e
    # もしエラーが発生した場合、エラーメッセージをログに記録
    Rails.logger.error("OpenAI APIエラー: #{e.message}")

    # エラー発生時にはユーザーに返すメッセージ
    "現在AIからアドバイスを受けることができません。後ほどお試しください。"
  end
end
