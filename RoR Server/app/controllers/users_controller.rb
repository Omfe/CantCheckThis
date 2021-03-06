class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end
  
  # GET /users_list
  def users_list
    @users = User.all
  end
  
  # POST /forgot_password
  def forgot_password
    email = (params[:email])
    User.all.each do |user|
      if user.email == email
        random_password = Array.new(10).map { (65 + rand(58)).chr }.join
         user.password = random_password
         user.save!
        UserMailer.send_forgot_password_email(user, random_password).deliver
        render json: {status: 'Email has been sent'}, status: 200
        return
      end
    end
    render json: {status: 'Invalid Email'}, status: 422
  end
  
  def reset_password
    user = current_user
    new_password = params[:new_password]
    if user.password == params[:old_password]
      user.password = new_password
      user.save!
      render json: {status: 'Password Changed Successfully'}, status: 200
    else
    render json: {status: 'Incorrect Password'}, status: 422
    end
  end
  
  # POST /register
  def register
    @user = User.new(user_params)
    @user.password = params[:password]
    @user.generate_remember_token
    @user.points = 0
    respond_to do |format|
      if @user.save
        format.json { render :register, status: :created, location: @user }
      else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /users
  # POST /users.json
  def create
    puts "bla <<<<<<<<<<<<<<<<<<<<<<<"
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
        sign_in @user
        flash[:success] = "Dont be late!"
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # POST /update_user
  def update_user
    @user = current_user
    respond_to do |format|
      if @user.update(user_params)
        format.json { render :show, status: :ok, location: @user }
      else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :points, :is_admin, :schedule_id)
    end
end
