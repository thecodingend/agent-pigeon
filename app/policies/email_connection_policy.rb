# frozen_string_literal: true

class EmailConnectionPolicy < ApplicationPolicy
  def check_dns?
    update?
  end

  private

  def owner?
    user.present? && record.agent.user_id == user.id
  end
end
