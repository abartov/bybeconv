# frozen_string_literal: true

# common methods to work with involved authorities
module RecordWithInvolvedAuthorities
  extend ActiveSupport::Concern

  # Returns list of authorities involved into given object with the given role.
  # Note: some roles can be specified both on Work and Expression level and this method will fetch only part of them.
  # If you need a full list use {#Manifestation.involved_authorities_by_role}
  # @param role [String/Symbol] role code
  def involved_authorities_by_role(role)
    role = role.to_s
    raise "Unknown role #{role}" unless InvolvedAuthority.roles.keys.include?(role)

    involved_authorities.to_a.select { |ia| ia.role == role.to_s }.map(&:authority)
  end
end
