class Gost < ActiveRecord::Base
  mount_uploader :file, FileUploader
end
