class Gost341012
  require "securerandom"
  include GostsHelper

  def initialize p, q, a, b, x, y
    @p = p.to_i(16)
    @q = q.to_i(16)
    @a = a.to_i(16)
    @b = b.to_i(16)
    @x = x.to_i(16)
    @y = y.to_i(16)
    r1 = @y * @y % @p
    r2 = ((@x * @x + @a) * @x + @b) % @p
    r2 += @p if r2 < 0
    raise "Invalid parameters" if r1 != r2
  end

  def public_key private_key
    p = [@x, @y]
    return exp(private_key, p)
  end

  def exp degree, p1
    p = @p
    a = @a
    r = mulEC(a, p, p1, degree)
    r1 = r[0]
    r2 = r[1]
    return r1, r2
  end

  def sign private_key, digest, size=64
    raise "Invalid digest length" if [digest].pack("H*").size != size
    p = [@x, @y]
    e = digest.to_i(16) % @q
    e = 1 if e == 0
    while true
      k = SecureRandom.random_bytes(size)
      k = encode_hex(k).to_i(16) % @q
      next if k == 0
      r, yc = exp(k, p)
      r %= @q
      next if r == 0
      rd = private_key * r
      ke = k * e
      s = (rd + ke) % @q
      next if s == 0
      break
    end
    return long2bytes(r) + long2bytes(s)
  end

  def verify pubx, puby, digest, sign, size=64
    raise "Invalid digest length" if [digest].pack("H*").size != size
    raise "Invalid signature length" if sign.size != size * 2
    r = encode_hex(sign[0, size]).to_i(16)
    s = encode_hex(sign[size, size]).to_i(16)
    return "false" if r <= 0 or r >= @q or s <= 0 or s >= @q
    e = digest.to_i(16) % @q
    e = 1 if e == 0
    v = invert(e, @q)
    z1 = s * v % @q
    z2 = @q - r * v % @q
    p = [@x, @y]
    p1x, p1y = exp(z1, p)
    q = [pubx, puby]
    q1x, q1y = exp(z2, q)
    lm = q1x - p1x
    lm += @p if lm < 0
    lm = invert(lm, @p)
    z1 = q1y - p1y
    lm = lm * z1 % @p
    xc = lm * lm % @p
    xc = xc - p1x - q1x
    xc = xc % @p
    xc += @p if xc < 0
    xc %= @q
    return "True" if xc == r
    return "False"
  end
end
