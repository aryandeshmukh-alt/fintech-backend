class AuditLog < ApplicationRecord
  validates :event_type, :entity_type, :entity_id, presence: true
end
