class UsersController < ApplicationController

  prepend_before_filter :reset_session_user
  
  # GET /users
  # GET /users.json
  def index
    @users = User.order(:name)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_url,
          notice: "User #{@user.name} was successfully created." }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      unless @session_user.can_edit_su?
        params[:user][:superuser] = @user.superuser
      end
      if @user.update_attributes(params[:user])
        format.html do
          if @user.superuser?
            redirect_to(users_url,
                        notice: "User #{@user.name} was successfully updated.")
          else
            redirect_to(user_url,
                        notice: "User #{@user.name} was successfully updated.")
          end
        end
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  protected

  def reset_session_user
    @session_user = nil
  end
  
  def authorize
    unless User.count.zero?
      @session_user = User.find_by_id(session[:user_id])
      if !@session_user
        redirect_to login_url, notice: "Authorized access only"
      elsif !@session_user.superuser?
        if !params[:id]
          redirect_to(login_url,
                      notice: "Superuser access only")
        else 
          param_user = User.find_by_id(params[:id])
          if @session_user != param_user
            redirect_to(login_url,
                        notice: "Superuser or same user access only")
          end
        end
      end      
    end
  end

  
end
