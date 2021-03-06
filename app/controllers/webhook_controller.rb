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
            case event.message['text']
            when /http(s|)/
              url = event.message['text']
              url.slice!(/http(s|):\/\/(www.|)/,0)
              urls = url.split("/")
              # urls[0] ドメイン
              text = "このコミックは現在通知できません。"
              user = User.find_by(line_user_id: event['source']['userId'])

              compare_url = ""
              compare_urls = Array.new()

              Site.all.each do |site|
                compare_url = site.url
                compare_url.slice!(/http(s|):\/\/(www.|)/,0)
                compare_urls = compare_url.split("/")

                if compare_urls[0] == urls[0]
                  @methods = site.method.split(" ")
                  @methods[0] = @methods[0].to_i if @methods[0]
                  @methods[3] = @methods[3].to_i if @methods[3]

                  if @methods[3] == 1
                    # ここで登録するURLが特殊なサイトの処理
                    agent = Mechanize.new
                    agent.user_agent_alias = 'Windows Mozilla'
                    page = agent.get(event.message['text'])

                    case site.id
                    when 1
                      # ジャンププラス
                      search_values = page.search("[@class='series-episode-list-container']")
                      url = search_values.last.get_attribute(:href)
                    end

                    url.slice!(/http(s|):\/\/(www.|)/,0)
                    # 特殊サイト以外のURLは行っているから
                  end

                  url.slice!(/#{Regexp.new(compare_url)}/)
                  text = "url一致"

                  begin
                    comic = site.comics.find_by(url: url)
                    comic = site.comics.create(url: url) unless comic
                  rescue
                    comic = site.comics.create(url: url)
                  end

                  break
                end
              end

              if user.bookmarking?(comic.id)
                user.unbookmark(comic.id)
                text = "ブックマークを解除しました。"
              else
                user.bookmark(comic.id)
                text = "ブックマークしました。"
              end

              message = {
                type: 'text',
                text: "#{text}"
              }
              response = client.reply_message(event['replyToken'], message)
            else
              message = {
                type: 'text',
                text: "webコミックのURLをお送りください"
              }
              response = client.reply_message(event['replyToken'], message)
              p response
            end
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
