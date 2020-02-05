class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    ratingVals = get_ratings()
    @all_ratings = ratingVals
    
    if params[:orderNameAsc] == "true"
      @movies = Movie.all.reorder(:title)
      @titleClass = "hilite, bg-warning"
    elsif params[:orderDateAsc] == "true"
      @movies = Movie.all.reorder(:release_date)
      @ratingClass = "hilite, bg-warning"
    else
      @movies = Movie.all.reorder(nil)
    end
    
    # Ratings handler
    selectedRatings = Array.new
    if params[:ratings] != nil
      params[:ratings].each do |key, value|
        selectedRatings.push key
      end
      # puts selectedRatings
      # puts Movie.all.length
      # @movies = Movie.with_ratings(selectedRatings)
      # puts Movie.all.length
      
      @movies = Movie.with_ratings(selectedRatings)
    end
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
  # User methods
  def get_ratings
    ary = Array.new
    Movie.all.each do |row|
      if !ary.include? row.rating
        ary.push row.rating
      end
    end
    return ary
  end
  
end
