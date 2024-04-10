namespace :fetch_sismic_data do
  desc 'Fetch and persist sismic data from USGS'
  task fetch: :environment do
    require 'open-uri'
    require 'json'

    url = 'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson?starttime=2024-03-10T00:00:00Z'
    response = URI.open(url)
    data = JSON.parse(response.read)

    data['features'].each do |feature|
      id = feature['id']
      properties = feature['properties']
      coordinates = feature['geometry']['coordinates']

      next if Feature.exists?(external_id: id)

      next if properties['title'].nil? || properties['url'].nil? || properties['place'].nil? || properties['magType'].nil? || coordinates[0].nil? || coordinates[1].nil?

      next unless (-1.0..10.0).include?(properties['mag']) &&
                  (-90.0..90.0).include?(coordinates[1]) &&
                  (-180.0..180.0).include?(coordinates[0])

      Feature.create(
        external_id: id,
        magnitude: properties['mag'],
        place: properties['place'],
        time: Time.at(properties['time'] / 1000),
        url: properties['url'],
        tsunami: properties['tsunami'],
        mag_type: properties['magType'],
        title: properties['title'],
        longitude: coordinates[0],
        latitude: coordinates[1]
      )
    end
  end
end
