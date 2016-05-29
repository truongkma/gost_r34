class Gost < ActiveRecord::Base

before_save :check_size_value

private
def check_size_value
  self.size = 256 if self.size != 512
end
end
