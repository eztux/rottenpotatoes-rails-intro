class Movie < ActiveRecord::Base
    def self.with_ratings(arr)
        return where(rating: arr)
    end
end
