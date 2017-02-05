require 'securerandom'
require 'pg'


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
    @database.name = @database.name.downcase
    @database.user = @user["uid"]
    @database.password = SecureRandom.urlsafe_base64(16)
    result = true
    if @database.postgres?
      result = create_postgresql_db(@database.name, @database.password)
    end

    if @database.mysql?
      result = create_mysql_db(@database.name, @database.password)
    end

    if result then
      result = @database.save
    end

    respond_to do |format|
      if result
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

    def create_postgresql_db(db, password)
      puts "************************"
      puts "* POSTGRES DB CREATION *"
      puts "************************"
      conn = PG.connect(host: SERVERS_INFOS["postgres"]["ip"],
                        port: SERVERS_INFOS["postgres"]["port"],
                        user: SERVERS_INFOS["postgres"]["user"],
                        password: SERVERS_INFOS["postgres"]["password"],
                        dbname: "postgres")
      puts "DB already exists ?"
      # On test si la DB existe déjà
      res = conn.exec_params("SELECT COUNT(*) from pg_database WHERE datname=$1",[db]);

      if res.getvalue(0,0) != "0" then
        puts "y"
        return false
      end
      puts "n"

      puts "Role already exists ?"
      # On test si l'utilisateur existe déjà
      res = conn.exec_params("SELECT COUNT(*) FROM pg_roles WHERE rolname=$1",[db]);
      if res.getvalue(0,0) != "0" then
        puts "y"
        return false
      end
      puts "n"


      # On essaie de créer la BDD et l'utilisateur
      begin
        puts "Creating user #{db} : #{password}"
        conn.exec("CREATE ROLE #{db} WITH LOGIN PASSWORD '#{password}'")
        puts "Creating db #{db}"
        conn.exec("CREATE DATABASE #{db}")
        puts "Grant"
        conn.exec("GRANT ALL PRIVILEGES ON DATABASE #{db} TO #{db}")
      rescue Exception => e
        puts e
        puts "Failed !"
        return false
      end
      puts "Done !"
      return true
    end


    def create_mysql_db(db, password)
      puts "*********************"
      puts "* MYSQL DB CREATION *"
      puts "*********************"

      conn = Mysql2::Client.new(:host => SERVERS_INFOS["mysql"]["ip"],
                                :username => SERVERS_INFOS["mysql"]["user"],
                                :password => SERVERS_INFOS["mysql"]["password"],
                                :port =>SERVERS_INFOS["mysql"]["port"],)

      edb = conn.escape db
      epassword = conn.escape password
      puts "Mysql DB exist ? "

      begin
        dbexists = conn.query "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '#{edb}'"
      rescue Mysql2::Error => e
        puts e
        puts "Failed !"
        return false
      end
      if dbexists.count != 0 then
        puts "y"
        return false
      end
      puts "n"

      puts "Mysql User exist ? "
      begin
         userexist = conn.query "SELECT 1 FROM mysql.user WHERE user = '#{edb}'"
      rescue Mysql2::Error => e
        puts e
        puts "Failed !"
        return false
      end
      if userexist.count != 0 then
        puts "y"
        return false
      end
      puts "n"

      # On essaie de créer la BDD et l'utilisateur
      begin
        puts "Creating user #{db} : #{password}"
        conn.query "CREATE USER #{edb} IDENTIFIED BY '#{epassword}';";
        puts "Creating db #{db}"
        conn.query "CREATE DATABASE IF NOT EXISTS #{edb};"
        puts "Grant"
        conn.query "GRANT ALL PRIVILEGES ON #{edb}. * TO #{edb};"
      rescue Mysql2::Error => e
        puts e
        puts "Failed !"
        return false
      end
      puts "Done !"
      return true
    end

    # def create_mongo_db(db,password)
    #   puts "*********************"
    #   puts "* MONGO DB CREATION *"
    #   puts "*********************"

    #   client = Mongo::Client.new(["#{SERVERS_INFOS["mongodb"]["ip"]}:#{SERVERS_INFOS["mongodb"]["port"]}"],
    #                           user: SERVERS_INFOS["mongodb"]["user"],
    #                           password: SERVERS_INFOS["mongodb"]["password"])

    #   puts client[:system].users.find({user:db}).count()
    # end
end
