class GostsController < ApplicationController
  include GostsHelper
  before_action :load_gost, only: [:show, :update]

  def update
    if params[:commit] == "Signature"
      @gost.update_attributes(check: "Signature")
      if params[:gost][:file].present?
        hash_file
        sign @gost.hexdigest, @gost.size / 8
      else
        @gost.update_attributes gost_params
        gost341112 = Gost341112.new @gost.message, @gost.size
        @digest = gost341112.hexdigest
        @gost.update_attributes(hexdigest: @digest)
        sign @gost.hexdigest, @gost.size / 8
      end
      redirect_to root_path
      flash[:success] = "Caculate signature success"
    else
      @gost.update_attributes(check: "Verify", signature: params[:gost][:signature],
        hexdigest: params[:gost][:digest])
      redirect_to root_path
    end
  end

  def show
    unless @gost.check == "Signature"
      p, q, a, b, x, y, d = check_size_digest
      curve = Gost341012.new p, q, a, b, x, y
      pub = curve.public_key d
      @verify = curve.verify pub[0], pub[1], @gost.hexdigest, [@gost.signature].pack("H*"), @gost.size / 8
    end
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

  def sign digest, size
    p, q, a, b, x, y, d = check_size_digest
    curve = Gost341012.new p, q, a, b, x, y
    signature = curve.sign d, digest, size
    @gost.update_attributes(signature: encode_hex(signature))
  end

  def hash_file
    @gost.update_attributes(file: params[:gost][:file])
    gost = Gost341112.new "", params[:gost][:size]
    File.open(@gost.file.current_path, "rb") do |f|
      while true
        buf = f.read(2**20)
        break if not buf
        gost.update buf
      end
    end
    @gost.update_attributes(hexdigest: gost.hexdigest, message: "file_upload",
      size: params[:gost][:size])
  end
end
