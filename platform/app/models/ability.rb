class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Article, public: true

    return unless user.present?

    can :manage, Article, user_id: user.id
    can :report, Article
  end
end