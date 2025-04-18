module ApplicationHelper
  def flash_background_color(type)
    case type.to_sym
    when :notice then "bg-green-500"
    when :alert  then "bg-red-500"
    end
  end

  def default_meta_tags
    {
      site: "ProgramRoutineMate",
      title: "ProgramRoutineMate",
      reverse: true,
      charset: "utf-8",
      description: "プログラミング学習継続アプリです。",
      canonical: request.original_url,
      og: {
        site_name: "ProgramRoutineMate",
        title: "ProgramRoutineMate",
        description: "プログラミング学習継続アプリです",
        type: "website",
        url: request.original_url,
        image: image_url("Program_Routine_Mate.png"),
        local: "ja-JP"
      },
      twitter: {
        card: "summary_large_image",
        site: "@https://x.com/58a_tanakaryo",
        image: image_url("Program_Routine_Mate.png")
      }
    }
  end
end
