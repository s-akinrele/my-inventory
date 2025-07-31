class Product < ApplicationRecord
  validates :title, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :vendor_id, presence: true
  validates :sku, presence: true, uniqueness: true
  
  belongs_to :vendor
end
