class Api::ListsController < ApiController

  def index
    user = find_user
    return user_not_found_error unless user

    if params[:password] && user.authenticate?(params[:password])
      render json: user.lists
    else
      render json: user.lists.public
    end
  end

  def create
    user = find_user
    return user_not_found_error unless user
    return permission_denied_error if !user.authenticate?(params[:password])

    list = user.lists.build new_list_params
    if list.save
      render json: list, root: false, status: :created #201
    else
      error :unprocessable_entity, list.errors.full_messages #422
    end
  end

  private

  def new_list_params
    params.permit(:user_id, :name, :permissions)
  end

  def find_user
    User.where(id: params[:user_id]).first
  end


end