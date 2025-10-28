class SessionsController < ApplicationController
  def new
  end

  def create
    # example login logic — adjust for your app
    # You may not have authentication yet, so just simulate success
    redirect_to root_path, notice: "Logged in successfully."
  end

  def destroy
    # example logout logic — adjust as needed
    redirect_to login_path, notice: "Logged out successfully."
  end
end
