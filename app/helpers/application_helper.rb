module ApplicationHelper
  def flash_background_color(type)
    case type.to_sym
    when :notice then "bg-green-500"
    when :alert  then "bg-red-500"
    end
  end

  def page_title(title = "")
    base_title = "RUNTEQ BOARD APP"
    title.present? ? "#{title} | #{base_title}" : base_title
  end

  def default_meta_tags
    {
      site: "ProgramRoutineMate",
      title: "プログラミング学習を共有するアプリです",
      reverse: true,
      charset: "utf-8",
      description: "初学者がプログラミング学習を継続し、他の学習者と共有するアプリです。",
      keywords: "プログラミング, 学習, 継続, 初学者",
      canonical: "https://program-routine-mate.com",
      separator: "|",
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: "website",
        url: "https://program-routine-mate.com",
        image: image_url("programroutinemate.png"),
        locale: "ja_JP"
      },
      twitter: {
        card: "summary_large_image",
        site: "@58a_tanaka_ryo",
        image: image_url("programroutinemate.png")
      }
    }
  end
end
