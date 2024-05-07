# frozen_string_literal: true

# common methods to work with involved authorities
module RecordWithInvolvedAuthorities
  extend ActiveSupport::Concern

  def involved_authorities_by_role(role)
    role = role.to_s
    raise "Unknown role #{role}" unless InvolvedAuthority.roles.keys.include?(role)

    involved_authorities.to_a.select { |ia| ia.role == role.to_s }.map(&:person)
  end
end
