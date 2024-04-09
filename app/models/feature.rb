class Feature < ApplicationRecord

  validates :external_id, presence: true
  validates :magnitude, presence: true, numericality: {greater_than_or_equal_to: -1.0, less_than_or_equal_to: 10.0}
  validates :place, presence: true
  validates :mag_type, presence: true, inclusion: { in: %w(md ml ms mw me mi mb mlg) }
  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90.0, less_than_or_equal_to: 90.0 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }

  has_many :comments
end
