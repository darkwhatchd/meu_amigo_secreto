# frozen_string_literal: true

class Campaign < ApplicationRecord
  before_validation :set_member, on: :create
  before_validation :set_status, on: :create
  belongs_to :user
  has_many :members, dependent: :destroy
  enum status: %i[pending finished]
  validates :title, :description, :user, :status, presence: true

  private

  # Inicia a campanha com o status pendente
  def set_status
    self.status = :pending
  end

  # Adiciona o criador da campanha como membro dela
  def set_member
    members << Member.create(name: user.name, email: user.email)
  end
end
