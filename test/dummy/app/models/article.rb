class Article < ActiveRecord::Base
  belongs_to :admin_user, optional: true
  has_many :comments
  has_and_belongs_to_many :magazines
  has_one :profile
  accepts_nested_attributes_for :profile, allow_destroy: true
  accepts_nested_attributes_for :comments, allow_destroy: true
  serialize :properties, type: Array, coder: YAML

  def non_orderable_column
    "Not orderable"
  end

  def to_s
    title
  end
end
