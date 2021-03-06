class FriendsController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :check_if_logged_in

  # CREATE

  def new
  end

  def create

    @friendship = Friendship.create(user_id: @current_user.id, friend_id: params[:user_id], status: "pending" )
    # redirect_to user_path(params[:user_id])
    ActionCable.server.broadcast "messages_#{params[:user_id]}",
      type: "friend_request",
      status: "pending",
      user_name: @current_user.name,
      user_id: @current_user.id

    render json: @friendship
  end

  # READ

  def index
    @friends = @current_user.friends
  end

  def show
    @friend = Friendship.find params[:id]
  end

  # UPDATE

  def edit
    @friendship = Friendship.where(user_id: params[:user_id], friend_id: @current_user.id)
  end

  def update
    @friendship = Friendship.where(user_id: params[:user_id], friend_id: @current_user.id)

    @friendship.update(status: "confirmed")

    ActionCable.server.broadcast "messages_#{params[:user_id]}",
      type: "friend_request",
      status: "confirmed",
      user_name: @current_user.name,
      user_id: @current_user.id

    render json: @friendship
    # redirect_to user_path(params[:user_id])
  end

  # DELETE

  def destroy
    @friendship = Friendship.where(user_id: @current_user.id, friend_id: params[:user_id]).or(Friendship.where(user_id: params[:user_id], friend_id: @current_user.id))
    @friendship.destroy_all
    redirect_to user_friends_path(@current_user.id)
  end

end #
