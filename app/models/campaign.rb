# frozen_string_literal: true

class Campaign < ApplicationRecord
  belongs_to :user
  has_many :members, dependent: :destroy
  before_create :set_member
  before_create :set_status
  enum status: %i[pending finished]
  validates :title, :description, :user, :status, presence: true

  # Inicia a campanha com o status pendente
  def set_status
    self.status = :pending
  end

  # Adiciona o criador da campanha como membro dela
  def set_member
    members << Member.create(name: user.name, email: user.email)
  end
end
