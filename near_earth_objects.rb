require 'faraday'
require 'figaro'
require 'pry'
require 'json'
# Load ENV vars via Figaro
Figaro.application = Figaro::Application.new(environment: 'production', path: File.expand_path('../config/application.yml', __FILE__))
Figaro.load

class NearEarthObjects

  def initialize(date)
    conn = Faraday.new(
      url: 'https://api.nasa.gov',
      params: { start_date: date, api_key: ENV['nasa_api_key']}
    )
    asteroids_list_data = conn.get('/neo/rest/v1/feed')
    @parsed_asteroids_data = JSON.parse(asteroids_list_data.body, symbolize_names: true)[:near_earth_objects][:"#{date}"]
  end
  # def self.find_neos_by_date(date)
  #   conn = Faraday.new(
  #     url: 'https://api.nasa.gov',
  #     params: { start_date: date, api_key: ENV['nasa_api_key']}
  #   )
  #   asteroids_list_data = conn.get('/neo/rest/v1/feed')
  #   parsed_asteroids_data = JSON.parse(asteroids_list_data.body, symbolize_names: true)[:near_earth_objects][:"#{date}"]

  def largest_astroid_diameter
    largest_astroid_diameter_array = @parsed_asteroids_data.map do |astroid|
      astroid[:estimated_diameter][:feet][:estimated_diameter_max].to_i
    end.max { |a,b| a<=> b}
    largest_astroid_diameter_array
  end

  def total_number_of_astroids
    @parsed_asteroids_data.count
  end

  # total_number_of_astroids = @parsed_asteroids_data.count
  def formatted_asteroid_data
    @parsed_asteroids_data.map do |astroid|
      {
        name: astroid[:name],
        diameter: "#{astroid[:estimated_diameter][:feet][:estimated_diameter_max].to_i} ft",
        miss_distance: "#{astroid[:close_approach_data][0][:miss_distance][:miles].to_i} miles"
      }
    end
  end
    # parsed_asteroids_data.map do |astroid|
    #   {
    #     name: astroid[:name],
    #     diameter: "#{astroid[:estimated_diameter][:feet][:estimated_diameter_max].to_i} ft",
    #     miss_distance: "#{astroid[:close_approach_data][0][:miss_distance][:miles].to_i} miles"
    #   }
    # end
  def find_neos_by_date
    {
      astroid_list: formatted_asteroid_data,
      biggest_astroid: largest_astroid_diameter,
      total_number_of_astroids: total_number_of_astroids
    }
  end
end
