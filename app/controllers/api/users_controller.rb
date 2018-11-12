class Api::UsersController < ApiController
 
  before_action :authenticated?
 
   def index
   end

 end
  def destroy
     begin
       user = User.find(params[:id])
       user.destroy
# #1
       render json: {}, status: :no_content
     rescue ActiveRecord::RecordNotFound
       render :json => {}, :status => :not_found
     end
   end

  def index
    return permission_denied_error unless authenticated?
    users = User.all
    render json: users, each_serializer: UsersSerializer
  end

  def create
    return permission_denied_error unless authenticated?
    user = User.new(new_user_params)
    if user.save
      render json: user, root: false, status: :created # 201
    else
      error :unprocessable_entity, user.errors.full_messages #422
    end
  end

  private

  def new_user_params
    params.permit(:username, :password)
  end

  def authenticated?
    authenticate_with_http_basic {|u, p| User.where( username: u, password: p).present? }
  end
def update
   list = List.find(params[:id])
   if list.update(list_params)
     render json: list
   else
     render json: { errors: list.errors.full_messages }, status: :unprocessable_entity
   end
 end
end
