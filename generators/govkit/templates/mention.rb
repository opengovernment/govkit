# A model to contain mentions of the :owner in the media
class Mention < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true

  scope :since, lambda { |d| where(["mentions.date > ?", d]) }

  # Returns the mentions in JSON form
  # 
  # @params [Hash] A hash of options
  # @return The mentions in JSON form
  def as_json(opts = {})
    default_opts = {:except => [:owner_id, :owner_type]}
    super(default_opts.merge(opts))
  end
end
