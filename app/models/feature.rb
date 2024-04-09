class Feature < ApplicationRecord
  validates :external_id, presence: true
  validates :magnitude, presence: true, numericality: { greater_than_or_equal_to: -1.0, less_than_or_equal_to: 10.0 }
  validates :place, presence: true
  validates :mag_type, presence: true, inclusion: { in: %w(md ml ms mw me mi mb mlg) }
  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90.0, less_than_or_equal_to: 90.0 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180.0, less_than_or_equal_to: 180.0 }
  attribute :url, :string

  has_many :comments

  def self.import_from_feed
    require 'net/http'
    require 'json'

    url = URI.parse('https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson')
    response = Net::HTTP.get_response(url)
    data = JSON.parse(response.body)

    data['features'].each do |feature_data|
      external_id = feature_data['id']
      properties = feature_data['properties']
      geometry = feature_data['geometry']

      next if Feature.exists?(external_id: external_id)

      feature = Feature.new(
        external_id: external_id,
        magnitude: properties['mag'],
        place: properties['place'],
        time: Time.at(properties['time'] / 1000), # Convertir milisegundos a segundos
        url: properties['url'], 
        tsunami: properties['tsunami'],
        mag_type: properties['magType'],
        title: properties['title'],
        longitude: geometry['coordinates'][0],
        latitude: geometry['coordinates'][1]
      )

      feature.save if feature.valid?
    end
  end
end
