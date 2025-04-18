module ApplicationHelper
  def flash_background_color(type)
    case type.to_sym
    when :notice then "bg-green-500"
    when :alert  then "bg-red-500"
    end
  end

  def default_meta_tags
    {
      site: "ProramRoutineMate",
      title: "ProgramRoutineMate",
      reverse: true,
      charset: "utf-8",
      description: "みんなで学習記録を投稿しながらプログラミング学習習慣をつけましょう!",
      keywords: [ "プログラミング学習初心者", "学習", "プログラミング" ],
      canonical: request.original_url,
      separator: "|",
      icon: [
        { href: image_url("icon.png") },
        { href: image_url("icon.png"), rel: "apple-touch-icon", sizes: "180x180", type: "image/png" }
      ],
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: "website",
        url: request.original_url,
        image: image_url("icon.png"),
        local: "ja-JP"
      },
      twitter: {
        card: "summary_large_image",
        site: "@58a_tanaka_ry",
        image: image_url("icon.png")
      }
    }
  end
end
