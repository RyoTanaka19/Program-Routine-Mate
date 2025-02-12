class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :study_logs, dependent: :destroy
  has_many :learning_comments, dependent: :destroy

  def own?(object)
    id == object&.user_id
  end
end
