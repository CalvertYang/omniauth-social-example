class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, omniauth_providers: [:facebook]

  has_many :user_socials

  def self.find_for_oauth auth, signed_in_resource = nil
    # Get the user_social and user if they exist
    user_social = UserSocial.find_for_oauth(auth)

    # If a signed_in_resource is provided it always overrides the existing user
    # to prevent the user_social being locked with accidentally created accounts.
    # Note that this may leave zombie accounts (with no associated user_social) which
    # can be cleaned up at a later date.
    user = signed_in_resource ? signed_in_resource : user_social.user

    # Create the user if needed
    if user.nil?
      # Get the existing user by email if the provider gives us a verified email.
      # If no verified email was provided we assign a temporary email and ask the
      # user to verify it on the next step via UsersController.finish_signup
      email = auth.info.email
      user = User.where(email: email).first if email

      # Create the user if it's a new registration
      if user.nil?
        user = User.new(
          name: auth.extra.raw_info.name,
          email: email,
          password: Devise.friendly_token[0,20]
        )
        user.save!
      end
    end

    # Associate the user_social with the user if needed
    if user_social.user != user
      user_social.user = user
      user_social.save!
    end

    user
  end
end
