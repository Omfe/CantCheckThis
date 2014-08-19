class SessionsController < ApplicationController
  before_filter :restrict_access
  
  def new
  end

  def create
    puts "entre <<<<<<<<<<<<<<<<<<<<"
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      user.generate_remember_token
      
      respond_to do |format|
        if user.save!
          format.json { render json: {test: "test"}, status: :created}
        else
          format.json { render json: user.errors, status: :unprocessable_entity }
        end
      end
    else
      render json: {status: "Invalid user name or password"}, status: :unprocessable_entity
    end
  end

  def destroy
    puts "entre #{current_user.inspect} <<<<<<<<<<<<<<<<<<<<"
    user = current_user
    
    user.remember_token = nil
    if user.save
      render json: {status: "Si se borro"}, status: 200
    else
      render json: {status: "Creo que no se borro"}, status: :unprocessable_entity
    end
  end 
end
#buscar por token a user, borrarle token y  volver success