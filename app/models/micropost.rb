class Micropost < ApplicationRecord
  MICROPOST_PARAMS = %i(content image).freeze
  belongs_to :user
  has_one_attached :image

  scope :newest, ->{order(created_at: :desc)}
  scope :relate_post, ->(user_ids){where user_id: user_ids}
  validates :content, presence: true, length: {maximum: Settings.digit_140}
  validates :image, content_type: {in: Settings.image.type,
                                   message: I18n.t("message.img_format")},
            size: {less_than: Settings.image.max_size.megabytes,
                   message: I18n.t("message.img_format")}

  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [Settings.image.max_height,
                                                   Settings.image.max_width]
  end
end
