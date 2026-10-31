class ApplicationController < ActionController::Base
  before_action :set_categories
  before_action :cart

  def after_sign_in_path_for(resource)
    resource.role == 'admin' ? admin_index_path : index_path
  end

  private
  def authenticate_admin!
    authenticate_user!
    redirect_to index_path, alert: 'That page is for admins.' unless current_user.role == 'admin'
  end

  def refuse(message, path)
    flash[:alert] = message
    if request.xhr?
      render json: { error: message }, status: :unprocessable_content
    else
      redirect_to path
    end
  end

  def set_categories
    @categories = Category.sort_by_name
  end

  def cart
    session[:cart] ||= {} if user_signed_in?
    @cart = session[:cart]
    @cart_total = @cart.count if session[:cart]
  end

end
