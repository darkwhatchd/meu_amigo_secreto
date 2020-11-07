# frozen_string_literal: true

FactoryBot.define do
  factory :campaign do
    title         { FFaker::Lorem.word }
    description   { FFaker::Lorem.sentence }
    user
  end
end
