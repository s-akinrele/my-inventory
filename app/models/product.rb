class Product < ApplicationRecord
  validates :title, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :vendor_id, presence: true
  validates :sku, presence: true, uniqueness: true
  validates :sku, format: { with: /\A[A-Z0-9]+(?:-[A-Z0-9]+)*\z/, message: "must be uppercase letters and numbers with optional hyphens" }

  belongs_to :vendor
end
