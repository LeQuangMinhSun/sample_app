module UsersHelper
  def gravatar_for user, options = {size: Settings.gravatar.size}
    gravatar_id = Digest::MD5.hexdigest user.email.downcase
    size = options[:size]
    gravatar_url = "htpp://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag gravatar_url, alt: user.name, class: "gravatar"
  end

  def can_delete? user
    current_user.admin? && !current_user?(user)
  end
end
