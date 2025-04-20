# 学習バッジ（StudyBadge）を保存するテーブルを作成するマイグレーション
class CreateStudyBadges < ActiveRecord::Migration[7.2]
  def change
    # study_badges テーブルの作成
    create_table :study_badges do |t|
      # バッジの名称（例:「連続ログイン7日」など）。null不可。
      t.string :name, null: false

      # バッジの説明文。どのような条件で付与されるかなどを記述。null不可。
      t.text :description, null: false

      # バッジに対応するアイコンのファイル名やURLなどを保存。null不可。
      t.string :icon, null: false

      # 作成日時・更新日時を自動的に記録（created_at, updated_at）
      t.timestamps
    end
  end
end
