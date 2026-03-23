class Magazine < ActiveRecord::Base
  has_and_belongs_to_many :articles

  def to_s
    name
  end
end
