class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  respond_to :json

  private

  def permission_denied_error
    error(403, 'Permission Denied')
  end

  def user_not_found_error
    error(404, 'User not found')
  end

  def error(status, message = 'Something went wrong')
    response = {
      response_type: 'ERROR',
      message: message
    }
    render json: response.to_json, status: status
  end
end