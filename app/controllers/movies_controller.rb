class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
    
    # Update flash and redirect using it
    flash[:order] = session[:order]
    flash[:ratings] = session[:ratings]
  end

  def index
    
    
    # Get all possible rating values
    ratingVals = get_ratings()
    @all_ratings = ratingVals
    
    # If there is no session value or param value return all movies
    if session[:ratings] == nil and session[:order] == nil and params[:order] == nil and params[:ratings] == nil
      @movies = Movie.all
      return
    end
    
    # initialize session value if nil
    if(session[:ratings] == nil or (session[:ratings] != params[:ratings] and params[:ratings] != nil))
      session[:ratings] = params[:ratings]
    end
    
    # Ratings handler
    selectedRatings = Array.new
    if session[:ratings] != nil
      session[:ratings].each do |key, value|
        selectedRatings.push key
      end
      @movies = Movie.with_ratings(selectedRatings)
      
    end
    
    # initialize session value of order
    if(session[:order] == nil or (session[:order] != params[:order] and params[:order] != nil))
      session[:order] = params[:order]
    end
    
    # Make sure that @movies is populated
    if @movies == nil
      @movies = Movie.all
    end
    
    # Order handler
    if session[:order] == "title"
      @movies = @movies.all.reorder(:title)
      @titleClass = "hilite, bg-warning"
      session[:order] = "title"
      
    elsif session[:order] == "date"
      @movies = @movies.all.reorder(:release_date)
      @ratingClass = "hilite, bg-warning"
      session[:order] = "date"
      
    else
      puts "I didn't get a proper order!"
    end
    
    params[:order] = session[:order]
    params[:ratings] = session[:ratings]
    
    # If fixing the params, stop here
    if(flash[:redirect])
      return
    end
    
    flash[:redirect] = true
    flash.keep
    
    redirect_to movies_path params
    
    
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
    
    # Update flash and redirect using it
    flash[:order] = session[:order]
    flash[:ratings] = session[:ratings]
    
    redirect_to movies_path flash
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
