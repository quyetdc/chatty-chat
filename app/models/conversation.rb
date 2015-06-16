class Conversation < ActiveRecord::Base
  belongs_to :sender, :foreign_key => :sender_id, class_name: 'User'
  belongs_to :recipient, :foreign_key => :recipient_id, class_name: 'User'

  has_many :messages, dependent: :destroy

  # to ensure that each pair of sender and recipient has only one conversation
  validates_uniqueness_of :sender_id, :scope => :recipient_id

  # scope conversation includes a user in it
  scope :involving, -> (user) do
    where("conversations.sender_id = ? OR conversations.recipient_id = ?", user.id, user.id)
  end

  # scope conversation between two users
  scope :between, -> (sender_id, recipient_id) do
    where(
        "(conversations.sender_id = ? AND conversations.recipient_id = ?) OR (conversations.sender_id = ? AND conversations.recipient_id = ?)",
        sender_id,
        recipient_id,
        recipient_id,
        sender_id
    )
  end
end
