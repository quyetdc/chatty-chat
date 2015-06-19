class MessagesController < ApplicationController
  before_filter :authenticate_user!

  def create
    @conversation = Conversation.find(params[:conversation_id])
    @message = @conversation.messages.build(message_params)
    @message.user_id = current_user.id
    @message.save!

    # This path is used in create.js.erb to publish notification to this channel
    @path = conversation_path(@conversation)

    # Publish notification to recipient channel
    rip = current_user == @conversation.recipient ? @conversation.sender : @conversation.recipient
    PrivatePub.publish_to("/notifications" + rip.id.to_s, cid: @conversation.id, sid: current_user.id, rip: rip.id)
    # render json: { message: @message }
  end

  private

  def message_params
    params.require(:message).permit(:body)
  end
end