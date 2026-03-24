class Profile < ActiveRecord::Base
  belongs_to :article

  def to_s
    bio.to_s
  end
end
