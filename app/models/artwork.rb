class Artwork < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items

  has_many_attached :images

  scope :published, -> { where(published: true) }
  scope :by_sub_category, ->(sub) { where(sub_category: sub) }
end
