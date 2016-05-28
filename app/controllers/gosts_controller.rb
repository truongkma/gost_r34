class GostsController < ApplicationController
  include GostsHelper
  before_action :load_gost, only: [:show, :update]

  def update
    if @gost.update_attributes gost_params
      redirect_to gost_path
    end
  end

  def show
    m = [@gost.str].pack("H*")
    @gost341112 = Gost341112.new m
    @gost.hash_value = @gost341112.hexdigest
  end

  private
  def load_gost
    @gost = Gost.find params[:id]
  end

  def gost_params
    params.require(:gost).permit :str
  end
end
