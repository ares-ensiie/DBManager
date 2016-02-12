require 'securerandom'

class DatabasesController < ApplicationController
  before_action :set_database, only: [:show, :edit, :update, :destroy]

  # GET /databases
  # GET /databases.json
  def index
    @databases = Database.where(:user => @user["uid"])
  end

  # GET /databases/1
  # GET /databases/1.json
  def show
  end

  # GET /databases/new
  def new
    @database = Database.new
  end

  # POST /databases
  # POST /databases.json
  def create
    @database = Database.new(database_params)
    @database.user = @user["uid"]
    @database.password = SecureRandom.urlsafe_base64(16)
    respond_to do |format|
      if @database.save
        format.html { redirect_to @database, notice: 'La base de données à bien été créée.' }
        format.json { render :show, status: :created, location: @database }
      else
        format.html { render :new }
        format.json { render json: @database.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /databases/1
  # DELETE /databases/1.json
  def destroy
    @database.destroy
    respond_to do |format|
      format.html { redirect_to databases_url, notice: 'La base de données à bien été supprimée.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_database
      @database = Database.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def database_params
      params.require(:database).permit(:name, :type)
    end
end
