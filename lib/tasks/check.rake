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
          text: "#{comic.name}の最新話が更新されました！\n#{comic.site.url}#{comic.url}"
        }
        client.push_message(line_user_id,message)

      end
    end

  end

  task :test => :environment do
    url = "https://shonenjumpplus.com/episode/10833519556325021909"
    url.slice!(/http(s|):\/\/(www.|)/,0)
    urls = url.split("/")
    text = "このコミックは現在通知できません。"

    Site.all.each do |site|
      compare_url = site.url
      compare_url.slice!(/http(s|):\/\/(www.|)/,0)
      compare_urls = compare_url.split("/")
      puts "#{urls[0]}\n#{compare_urls[0]}"
      if compare_urls[0] == urls[0]
        url.slice!(/#{Regexp.new(compare_url)}/)
        begin
          comic = site.comics.find(url: url)
          comic = site.comics.create!(url: url) unless comic
        rescue
          comic = site.comics.create!(url: url)
        end
        user = User.find_by(line_user_id: "U6a8c6f24f76db8ad13cbd846fb52dccc")
        user.bookmark(comic.id)
        text = "ブックマークしました。"
        puts "bookmark"
        break
      end
      puts "can't bookmark"
    end
  end
end
