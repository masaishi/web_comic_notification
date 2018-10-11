class WebhookController < ApplicationController
  require 'line/bot'
    protect_from_forgery :except => [:callback]


    def index

    end



    def callback
      body = request.body.read

      signature = request.env['HTTP_X_LINE_SIGNATURE']

      unless client.validate_signature(body, signature)
        error 400 do 'Bad Request' end
      end

      events = client.parse_events_from(body)
      events.each { |event|
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text

            # e_message = event.message['text'].split(" ")
            # if e_message.include?("kaka")
            message = {
              type: 'text',
              text: "#{event.source[userId]}"
            }
            response = client.reply_message(event['replyToken'], message)
            p response
          end
        when Line::Bot::Event::Follow
          user = User.new
          user.name = "unknown"
          user.line_user_id = event['source']['userId']
          user.save

          message = {
            type: 'text',
            text: "webコミックサイトから、通知をしたい作品のURLを送るとその作品をブックマークし、更新されたら通知します。"
          }
          response = client.reply_message(event['replyToken'], message)
          p response
        end
      }
      render status: 200, json: { message: 'OK' }
    end

    private
    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      }
    end
end
