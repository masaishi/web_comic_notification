class Comic < ApplicationRecord
  belongs_to :site

  has_many :passive_bookmarks, class_name: "Bookmark"
  has_many :bookmarked, through: :passive_bookmarks, source: :user

  def bookmark(user_id)
    passive_bookmarks.create(user_id: user_id)
  end
end
