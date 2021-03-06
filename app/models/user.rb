class User < ApplicationRecord
  has_many :targets, dependent: :destroy
  attr_accessor :login

  validates :name,  presence: true, length: { maximum: 30 }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:google], authentication_keys: [:login]


  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["name = :value OR lower(email) = lower(:value)", { :value => login }]).first
    else
      where(conditions).first
    end
  end

  def self.create_unique_string
    SecureRandom.uuid
  end

  def self.find_for_google(auth)
    user = User.find_by(email: auth.info.email)
    unless user
      user = User.new(name: auth.info.name,
                      email: auth.info.email,
                      provider: auth.provider,
                      uid:      auth.uid,
                      password: Devise.friendly_token[0, 20],
                    )
    end
    user.save
    user
  end
  mount_uploader :avatar, ImageUploader
end
