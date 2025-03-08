class Like < ApplicationRecord
  belongs_to :user
  belongs_to :study_log

  validates :user_id, uniqueness: { scope: :study_log_id } 
end
