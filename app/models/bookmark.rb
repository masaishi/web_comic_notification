class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :comic
  validates :user, presence: true
  validates :comic, presence: true
end
