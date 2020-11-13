# frozen_string_literal: true

class Member < ApplicationRecord
  belongs_to :campaign
  after_save :set_campaign_pending
  validates :name, :email, :campaign, presence: true

  def set_pixel
    self.open = false
    self.token = loop do
      # Gera um token aleatório
      # Verifica se outro membro não recebeu o mesmo token
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless Member.exists?(token: random_token)
    end
    save!
  end

  protected

  # Seta a campanha como pendente, após criar um novo membro
  def set_campaign_pending
    campaign.update(status: :pending)
  end
end
