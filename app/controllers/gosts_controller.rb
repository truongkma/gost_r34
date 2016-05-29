class GostsController < ApplicationController
  before_action :load_gost, only: [:show, :update]

  def update
    if @gost.update_attributes gost_params
      redirect_to gost_path
    end
  end

  def show
    p, q, a, b, x, y, d = check_size_degest
    m = [@gost.message].pack("H*")
    gost341112 = Gost341112.new m, @gost.size
    @digest = gost341112.hexdigest
    curve = Gost341012.new p, q, a, b, x, y
    @signature = curve.sign d, @digest, @gost.size / 8
    pub = curve.public_key d
    @verify = curve.verify pub[0], pub[1], @digest, @signature, @gost.size / 8
  end

  private
  def load_gost
    @gost = Gost.find params[:id]
  end

  def gost_params
    params.require(:gost).permit :message, :size
  end

  def check_size_degest
    if @gost.size == 256
      p = ENV["p1"]
      q = ENV["q1"]
      a = ENV["a1"]
      b = ENV["b1"]
      x = ENV["x1"]
      y = ENV["y1"]
      d = ENV["private_key1"].to_i(16)
    else
      p = ENV["p"]
      q = ENV["q"]
      a = ENV["a"]
      b = ENV["b"]
      x = ENV["x"]
      y = ENV["y"]
      d = ENV["private_key"].to_i(16)
    end
    return p, q, a, b, x, y, d
  end
end
