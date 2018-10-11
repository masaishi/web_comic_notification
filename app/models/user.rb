class User < ApplicationRecord
  has_many :active_bookmarks, class_name: "Bookmark", dependent: :destroy
  has_many :bookmarking, through: :active_bookmarks, source: :comic


  def bookmark(comic_id)
    active_bookmarks.create(comic_id: comic_id)
  end

  def unbookmark(comic_id)
    active_bookmarks.find_by(comic_id: comic_id).destroy
  end

  def bookmarking?(comic_id)
    bookmarking.include?(comic_id)
  end
end
