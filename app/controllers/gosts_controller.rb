class GostsController < ApplicationController
  before_action :load_gost, only: [:show, :update]

  def update
    if @gost.update_attributes gost_params
      redirect_to root_path
    end
  end

  def show
    p, q, a, b, x, y, d = check_size_digest
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

  def check_size_digest
    if @gost.size == 256
      p, q, a, b, x, y  = ENV["p1"], ENV["q1"], ENV["a1"], ENV["b1"], ENV["x1"], ENV["y1"]
      d = ENV["private_key1"].to_i(16)
    else
      p, q, a, b, x, y  = ENV["p"], ENV["q"], ENV["a"], ENV["b"], ENV["x"], ENV["y"]
      d = ENV["private_key"].to_i(16)
    end
    return p, q, a, b, x, y, d
  end
end
