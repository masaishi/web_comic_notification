namespace :check do
  require 'line/bot'
  desc "最新話をチェック"
  task :delete => :environment do
    Comic.all.each do |comic|
      comic.update(last_story: "ttsf3fs5tsfsdf")
    end
  end
  task :all => :environment do
    # スクレイピングについての初期設定
    notices = Hash.new()
    i = 0
    agent = Mechanize.new
    agent.user_agent_alias = 'Windows Mozilla'

    class Scraping
      def initialize(site, page)
        @methods = site.method.split(" ")
        @methods[0] = @methods[0].to_i if @methods[0]
        @methods[3] = @methods[3].to_i if @methods[3]

        @site_id = site.id
        @page = page
      end

      def get
        return_array = []
        if @methods[0] == 0
          if @methods[1] == "class"
            search_values = @page.search("[@class='#{@methods[2]}']")
          elsif @methods[1] == "id"
            search_values = @page.search("[@id='#{@methods[2]}']")
          end
        end

        # 漫画ごとの処理
        if @methods[3] == 1
          case @site_id
          when 1
            # ジャンププラス
            return_array[0] = search_values[0].xpath(".//h4").text.match(/\[(.+)\]/)[1]
            return_array[1] = search_values[0].get_attribute(:href)
          end
        else
          return_array[0] = search_values[0].content
        end


        return return_array
      end
    end

    # lineについての初期設定
    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      }
    end

    Site.all.each do |site|
      site.comics.all.each do |comic|
        begin
          page = agent.get(site.url + comic.url)
          scraping_array = Scraping.new(site, page).get
          if comic.last_story != scraping_array[0]
            comic.update(last_story: scraping_array[0])
            if scraping_array[1]
              comic.update(send_url: scraping_array[1])
            end
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
        rescue => error
          puts "失敗#{comic.url}"
          line_user_id = User.first.line_user_id
          message = {
            type: 'text',
            text: "管理者\nスクレイピングに失敗\ncomic_id :#{comic.id}\ncomic_url:#{comic.url}"
          }
          client.push_message(line_user_id, message)

          line_user_id.clear
          message.clear
        end
      end

      if i > 5000
        break
      end
    end

    notices.each do |key,notice|
      user = User.find(key)
      notice.each do |comic|
        if comic.send_url != false
          send_url =  comic.site.url + comic.url
        else
          send_url = comic.send_url
        end

        message = {
          type: 'text',
          text: "最新話が更新されました！\n#{send_url}"
        }
        client.push_message(user.line_user_id,message)
      end
    end
  end
end
