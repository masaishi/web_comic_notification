namespace :check do
  require 'line/bot'
  desc "最新話をチェック"
  task :delete => :environment do
    Comic.all.each do |comic|
      comic.update(last_story: "ttsf3fs5tsfsdf")
    end
  end
  task :all => :environment do
    puts "test"
    notices = Hash.new()
    i = 0

    Site.all.each do |site|
      @methods = site.method.split(" ")

      if @methods[0] == "0"
        case @methods[1]
        when "class"
          def selected_method() @page.at("[@class='#{@methods[2]}']").content end
        end
        when "id"
          def selected_method() @page.at("[@id='#{@methods[2]}']").content end
        end
      end

      agent = Mechanize.new
      agent.user_agent_alias = 'Windows Mozilla'

      site.comics.all.each do |comic|
        begin
          @page = agent.get(site.url + comic.url)
          last_story = selected_method()

          if comic.last_story != last_story
            comic.update(last_story: last_story)
            comic.bookmarked.all.each do |user|
              notices["#{user.id}"] = [] unless notices["#{user.id}"]

              notices["#{user.id}"] << comic
            end
          end

          i += 1
          sleep(rand(0.5..1.5))
          if i > 5000
            break
          end
        rescue
          puts "失敗#{comic}"
        end
      end

      if i > 5000
        break
      end
    end

    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      }
    end

    notices.each do |key,notice|
      line_user_id = User.find(key).line_user_id
      notice.each do |comic|
        message = {
          type: 'text',
          text: "最新話が更新されました！\n#{comic.site.url}#{comic.url}"
        }
        client.push_message(line_user_id,message)
      end
    end
  end
end
