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
      description: "ProgramRoutineMateは、プログラミング学習を継続的にサポートするアプリです。ユーザーが学習を記録し、モチベーションを維持するためのツールを提供します。",
      canonical: request.original_url,
      separator: "|",
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: "website",
        url: request.original_url,
        image: image_url("ogp.png"),
        local: "ja-JP"
      },
      twitter: {
        card: "summary_large_image",
        site: "@https://x.com/58a_tanakaryo",  # ユーザー名の形式に修正
        image: image_url("ogp.png")
      }
    }
  end
end
