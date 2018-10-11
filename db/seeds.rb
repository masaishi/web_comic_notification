10.times do |n|
  name = "user#{n}"
  User.create!(name: name, password: "password",line_token: "k3riuwsj")
end

def create_site(name,url,method)
  Site.create!(name: name, url: url,method: method)
end
def create_comic(site,name,url)
  site.comics.create!(name: name, url: url, last_story: "e8r7fsdio7")
end


site = create_site("ジャンププラス","https://shonenjumpplus.com/episode/","0 class series-episode-list-title")
create_comic(site,"ハンターハンター","10833519556325021810")
create_comic(site,"天神-TENJIN- イーグルネスト","10833497643049550183")

site = create_site("comic worker","https://comic-walker.com/contents/detail/","0 class detail_storyNum")
create_comic(site,"まったく最近の探偵ときたら","KDCW_AM01100032010000_68")
create_comic(site,"バケモノの子","KDCW_KS01000023010000_68")


users = User.order(:created_at).take(4)
comics = Comic.order(:created_at).take(4)
4.times do |n|
  users.each {|user| user.bookmark(comics[n].id)}
end
