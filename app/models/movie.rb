class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
  
class Movie::InvalidKeyError < StandardError ; end
  
  def self.find_in_tmdb(string)
    begin
      Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
    
      matching_movies = Tmdb::Movie.find(string)
      movies=[]
      if !matching_movies.nil?
        matching_movies.each do |movie|
          option = Hash.new(0);
          option[:tmdb_id]=movie.id;
          option[:title]=movie.title;
          option[:release_date]=movie.release_date;
          option[:rating]=get_rating(movie.id);
          movies.push(option);
        end
      end
      return movies
    rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end
  
  def self.create_from_tmdb(id)
    begin
      Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
      details = Tmdb::Movie.detail(id)
      movie = Hash.new
      movie[:title] = details["title"]
      movie[:rating] = get_rating(id)
      movie[:description] = details["overview"]
      movie[:release_date] = details["release_date"]
      Movie.create!(movie)
      rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end
  
  def self.get_rating(id)
    begin
      Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
      all_details = Tmdb::Movie.releases(id)
      specific_details = all_details["countries"].select { |country| country["iso_3166_1"] == "US" }
      if specific_details.size>0
        rating = specific_details[0]["certification"]
      else
        rating = ""
      end
      return rating
      rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end
  
end
