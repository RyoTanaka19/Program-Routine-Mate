class OpenAiService
  def self.generate_question(content, type: :written)
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    prompt = case type
    when :written
      I18n.t("open_ai.prompts.written", content: content)
    when :multiple_choice
      I18n.t("open_ai.prompts.multiple_choice", content: content)
    else
      raise ArgumentError, I18n.t("open_ai.errors.unsupported_type", type: type)
    end

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: I18n.t("open_ai.system_role.writing") },
          { role: "user", content: prompt }
        ],
        max_tokens: 300,
        temperature: 0.7
      }
    )

    response.dig("choices", 0, "message", "content")&.strip
  rescue => e
    Rails.logger.error(I18n.t("open_ai.errors.api_error", message: e.message))
    nil
  end

  def self.explain_answer(question_text, user_answer)
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    prompt = I18n.t("open_ai.prompts.explanation", question: question_text, answer: user_answer)

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: I18n.t("open_ai.system_role.explanation") },
          { role: "user", content: prompt }
        ],
        max_tokens: 300,
        temperature: 0.7
      }
    )

    response.dig("choices", 0, "message", "content")&.strip
  rescue => e
    Rails.logger.error(I18n.t("open_ai.errors.api_error", message: e.message))
    nil
  end
end
