namespace :check do
  desc "最新話をチェック"
  task :all => :environment do
    puts "test"
    notices = Hash.new()

    Site.all.each do |site|
      @methods = site.method.split(" ")

      if @methods[0] == "0"
        case @methods[1]
        when "class"
          def selected_method() @page.at("[@class='#{@methods[2]}']").content end
        end
      end

      site.comics.all.each do |comic|
        agent = Mechanize.new
        @page = agent.get(site.url + comic.url)
        last_story = selected_method()

        if comic.last_story != last_story
          comic.update(last_story: last_story)
          comic.bookmarked.all.each do |user|
            notices["#{user.id}"] = [] unless notices["#{user.id}"]

            notices["#{user.id}"] << comic
          end
        end

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
          text: "#{comic.name}の最新話が更新されました！"
        }
        client.push_messeage(line_user_id,message)

      end
    end

  end
end
