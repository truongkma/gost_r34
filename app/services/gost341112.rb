class Gost341112
  include GostsHelper

  BLOCKSIZE = 64

  def initialize data="", digest_size=512
    @data = data
    @digest_size = digest_size
  end

  def update data
    @data += data
  end

  def digest
    @data = [@data].pack("H*")
    if @digest_size == 256
      h = ["01"].pack("H*") * BLOCKSIZE
    else
      h = ["00"].pack("H*") * BLOCKSIZE
    end
    sigma = ["00"].pack("H*") * BLOCKSIZE
    n = 0
    data = @data.reverse
    value = data.size / BLOCKSIZE * BLOCKSIZE
    (0..value-1).step(BLOCKSIZE).each do |i|
      block = data[i, BLOCKSIZE]
      h = g(n, h, block)
      sigma = add(sigma, block)
      n += 512
    end
    padblock_size = data.size * 8 - n
    data += "\x01"
    padlen = BLOCKSIZE - data.size % BLOCKSIZE
    data += "\x00" * padlen if padlen != BLOCKSIZE
    h = g(n, h, data[-BLOCKSIZE, data.size])
    n += padblock_size
    sigma = add(sigma, data[-BLOCKSIZE, data.size])
    h = g(0, h, [n].pack("<Q") + ["00"].pack("H*") * 56)
    h = g(0, h, sigma)
    return h[32, h.size] if @digest_size == 256
    return h
  end

  def hexdigest
    encode_hex(digest.reverse)
  end
end
