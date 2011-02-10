class UsersController < ApplicationController
  
  before_filter :authorize, :except => [:forgot_password, :edit_password, :reset_password]
  before_filter :load_user_using_perishable_token, :only => [:edit_password, :reset_password]
  
  def index
    @user = current_user
  end
  
  def download
    type = params[:type]
    if type == 'hi'
      file = "VTS_Hindi_User_Guide.pdf"
    else
      file = "VTS_English_User_Guide.pdf"
    end
    
    file_path = "#{RAILS_ROOT}/public/downloads/#{file}"
    send_file file_path, :type => 'application/pdf'
  end
  
  def new
    if current_user.id == 1 && current_user.centre_id == 4068
      items_per_page = 20
      @user = User.new
      @centres = Centre.find(:all, :conditions => ["id != 4068 and id != 1 and id != 2"], :order => "name")
      @centreslist = User.paginate :per_page => items_per_page, :page => params[:page], 
                                   :conditions => ["centre_id != 4068 and centre_id != 1 and centre_id != 2"], 
                                   :include => [:centre], 
                                   :order => "centres.name"
    else
      redirect_to login_url
    end
  end
  
  def account
    @zones   = Zone.find(:all)
    if request.post?
      if current_user.id == 1 && current_user.centre_id == 4068
        name = params[:centre][:name].upcase
        centre = Centre.find(:first, :conditions => ["name = ?", name])
        if centre
          flash[:notice] = "This centre already exsits."
        else
          @address = Address.new()
          @address.addr1 = 'addr1'
          @address.city = 'city'
          @address.state = 'state'
          @address.pincode = 'code'
          @address.country = 'INDIA'
          @address.save
          
          @contact = Contact.new()
          @contact.save
          
          @account = Centre.new()
          @account.name = name
          @account.incharge = params[:centre][:incharge].upcase
          @account.centre_type = params[:centre][:centre_type]
          @account.zone_id = params[:centre][:zone_id]
          @account.address_id = @address.id
          @account.contact_id = @contact.id
          @account.save
          
          flash[:notice] = "Centre has been created."
        end
      end
    end
  end
  
  def create
    centre_id = params[:user][:centre_id]
    user = User.find(:first, :conditions => ["centre_id = ?", centre_id])
    
    if current_user.id == 1 && current_user.centre_id == 4068
      if !user
        @user = User.new(params[:user])
        @user.centre_id = centre_id
        if @user.save_without_session_maintenance
          #clear_authlogic_session
          message = "<div class='reg'>Successful, here are details of #{@user.centre.name} centre:"
          message += "<br/>Username : #{params[:user][:username]}"
          message += "<br/>Password : #{params[:user][:password]}"
          message += "<br/><p class='note'>Note : Please note above details, you can not retrive above details again.</p></div>"
          flash[:notice] = message
        else
          flash[:notice] = "Something went wrong, please check all fields and try again."
        end
      else
        flash[:notice] = "You have already assigned username and password for this centre."
      end
      redirect_to :action => 'new'
    else
      @user_session = UserSession.find
      @user_session.destroy
      flash[:notice] = "Successfully logged out."
      redirect_to login_url
    end
  end
  
  def edit
    @user    = current_user
    @zones   = Zone.find(:all)
    @centre  = Centre.find(@user.centre)
    @address = Address.find(@user.centre.address)
    @contact = Contact.find(@user.centre.contact)
  end
  
  def show
    @user    = current_user
    @centre  = Centre.find(@user.centre)
  end
  
  def update
    @user = current_user
    
    @centre  = Centre.find(@user.centre)
    @centre.update_attributes(params[:centre])
    
    @address = Address.find(@user.centre.address)
    @address.update_attributes(params[:address])
    
    @contact = Contact.find(@user.centre.contact)
    @contact.update_attributes(params[:contact])
    
    if @user.update_attributes(params[:user])
      flash[:notice] = "Successfully updated centre details."
      redirect_to info_url
    else
      render :action => 'edit'
    end
  end
  
  def password
    @user = current_user
  end
  
  def update_password
    @user = current_user
    
    pwd1 = params[:user][:password]
    pwd2 = params[:user][:password_confirmation]
    
    if pwd1.blank? && pwd2.blank?
      flash[:notice] = "Please check all fields and try again."
      render :action => 'password'
    else
      if params[:user][:password] == params[:user][:password_confirmation]
        if @user.update_attributes(params[:user])
          flash[:notice] = "Your account password has been updated."
          redirect_to info_url
        else
          flash[:notice] = "Something went wrong, please check all fields and try again."
          render :action => 'password'
        end
      else
        flash[:notice] = "Password and Confirm Password are not same."
        render :action => 'password'
      end
    end
  end
  
  def delete
    if current_user.id == 1 && current_user.centre_id == 4068
      @user = User.find(params[:id])
      if @user
        if @user.centre_id == 4068
          flash[:notice] = 'Can not delete this centre account'
        else
          Participant.destroy_all(:centre_id => @user.centre_id)
          Registration.destroy_all(:centre_id => @user.centre_id)
          @user.destroy
          flash[:notice] = 'Centre account removed'
        end
      else
        flash[:notice] = 'Unknown centre account'
      end
    end
    redirect_to :action => 'new'
  end
  
  def forgot_password
    if request.post?
      @user = User.find_by_username(params[:email], :conditions => ["id != 1"])
      if @user
        @user.deliver_password_reset_instructions!
        flash[:notice] = "Please check your email."
        redirect_to login_url
      else
        flash[:notice] = "No user was found with that email address"
        render :action => :forgot_password
      end
    end
  end
  
  def edit_password
    @token = params[:token]
  end
  
  def reset_password
    if request.post?
      @user.password = params[:password]
      @user.password_confirmation = params[:password_confirmation]
      if @user.save
        flash[:notice] = "Password successfully updated"
        redirect_to users_path
      end
    end
  end
  
  
  private
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:token], 2.hours)
    unless @user
      flash[:notice] = "We're sorry, but we could not locate your account. Please contact help desk."
      redirect_to root_url
    end
  end
  
end
