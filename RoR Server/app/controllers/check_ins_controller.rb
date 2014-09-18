class CheckInsController < ApplicationController
  before_action :set_check_in, only: [:show, :edit, :update, :destroy]

  # GET /check_ins
  # GET /check_ins.json
  def index
    @check_ins = CheckIn.all
  end

  # GET /check_ins/1
  # GET /check_ins/1.json
  def show
  end

  # GET /check_ins/new
  def new
    @check_in = CheckIn.new
  end
  
  # GET /check_ins/1/edit
  def edit
  end
  
  # POST/daily_report
  def daily_report
    str = (params[:date])
    date = Date.parse str
    @check_ins = CheckIn.where(created_at: (date.midnight)..date.midnight + 1.day)
  end
  
  # def did_previous_checkin
#     user = current_user
#     @check_ins = CheckIn.where(user_id: user.id)
#     @check_ins.each do |check_in|
#       if check_in.checked_in_at.strftime("%d") == Time.now.strftime("%d")
#         puts "Entro al de false"
#         false
#         return
#       end
#     end
#     true
#   end
  
  def did_previous_checkin
    user = current_user
    @check_ins = CheckIn.where(checked_in_at: DateTime.now.beginning_of_day..DateTime.now).where(user_id: user.id)
    if @check_ins.count > 0
      false
      return
    else
      true
    end
  end
  
  # POST /checkin
  def checkin
    if did_previous_checkin == true
      user = current_user
      @check_in = CheckIn.new(:checked_in_at => Time.now, :user_id => user.id)
      userTolerance = user.schedule.check_in + 30.minutes
      
      if userTolerance.strftime("%H%M") < @check_in.checked_in_at.strftime("%H%M")
        if user.points == nil
          user.points = 0
        end
        user.points = user.points + 1
        user.save!
        status = 0
      end
      
      if status == 0
        status = "You were late! +1 Point Added"
      else
        status = "Thank you for not being late!"
      end
      
      respond_to do |format|
        if @check_in.save
#          format.json { render :show, status: :created, location: @check_in }
          format.json { render :json => {:show => @check_in, :report => status}}
        else
          format.json { render json: @check_in.errors, status: :unprocessable_entity }
        end
      end
    else
      render json: {status: 'Cant Check This! Until Tomorrow...'}, status: 422
    end
  end

  # POST /check_ins
  # POST /check_ins.json
  def create
    @check_in = CheckIn.new(check_in_params)

    respond_to do |format|
      if @check_in.save
        format.html { redirect_to @check_in, notice: 'Check in was successfully created.' }
        format.json { render :show, status: :created, location: @check_in }
      else
        format.html { render :new }
        format.json { render json: @check_in.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /check_ins/1
  # PATCH/PUT /check_ins/1.json
  def update
    respond_to do |format|
      if @check_in.update(check_in_params)
        format.html { redirect_to @check_in, notice: 'Check in was successfully updated.' }
        format.json { render :show, status: :ok, location: @check_in }
      else
        format.html { render :edit }
        format.json { render json: @check_in.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /check_ins/1
  # DELETE /check_ins/1.json
  def destroy
    @check_in.destroy
    respond_to do |format|
      format.html { redirect_to check_ins_url, notice: 'Check in was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_check_in
      @check_in = CheckIn.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def check_in_params
      params.require(:check_in).permit(:checked_in_at)
    end
end

#Hacer la suma de puntos con los check ins y los horarios de los usuarios
