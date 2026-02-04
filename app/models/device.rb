class Device < ApplicationRecord
  belongs_to :user

  validates :device_id, presence: true
  validates :first_seen_at, presence: true
end
