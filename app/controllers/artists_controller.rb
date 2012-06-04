class ArtistsController < ApplicationController

  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: Artist.where("name like ?", "%#{params[:search]}%").order("name").to_json} 
    end
  end

  def show
    @artist = Artist.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @artist.to_json(include:[:albums]) }
    end

  end

  def update
    @artist = Artist.find(params[:id])

    respond_to do |format|
      if @artist.update_attributes(params[:artist])
        format.json { render json: @artist, status: :ok }
      else
        format.json { render json: @artist.errors, status: :unprocessable_entity }
      end
    end

  end

  # def search
  #    render :json => Artist.where("name like ?", "%#{params[:search]}%").to_json
  # end
end
