class GameController < WebsocketRails::BaseController
  def initialize_session
    # perform application setup here
    controller_store[:message_count] = 0
  end

  def test
    trigger_success({:message => "success! #{message[:title]}"})
  end
end