# encoding: utf-8
require 'rubygems'
require 'mechanize'
require 'sqlite3'
require 'colorize'
require './config/config.rb'
require './db/db.rb'

class JUScorer
  def initialize(riv = '60930007178425')
    @ext_total = @adv_total = @bas_total = 0
    @ext_num = @adv_num = @bas_num = 0
    @rival = riv # your own rival id
    login
    findUser
    start
  end

  #login the 573 website
  def login
    @agent = Mechanize.new
    @page = @agent.get 'https://p.eagate.573.jp/gate/p/login.html'
    @page.encoding = 'utf-8'

    form = @page.forms[0]
    form.KID = Config::USER
    form.pass = Config::PASS
    @page = @agent.submit(form)
  end

  def findUser
      #===========================================
      #TODO: Check the user whether exists
      #===========================================
      @page = @agent.get "http://p.eagate.573.jp/game/jubeat/prop/p/playdata/index_other.html?rival_id=#{ @rival }"

      #match title and nickname
      spans = @page.search("div#pname/span")
      @title = spans[0].text.strip
      @nick = spans[1].text.strip

      #match play detail
      play_detail = @page.search("td.right")
      @tune_num = play_detail[0].text.strip.to_i
      @fc_num = play_detail[1].text.strip.to_i
      @exc_num = play_detail[2].text.strip.to_i

      #match last_time, location and center
      bottom = @page.search("tr.bottom/td/div")
      temp = bottom.xpath('br/preceding-sibling::text()').text.strip
      /最終プレー日時：(.*)/ =~ temp
      @last_at = Regexp.last_match[1].strip
      temp = bottom.xpath('br/following-sibling::text()').text.strip
      /(.*) (.*)/ =~ temp
      @location = Regexp.last_match[1].strip
      @game_center = Regexp.last_match[2].strip

      @user = User.find_by(rival_id: @rival)
      if @user
        @user.update(nick: @nick, title: @title, last_at: @last_at, location: @location, game_center: @game_center, \
                     tune_num: @tune_num, fc_num: @fc_num, exc_num: @exc_num)
      else
        #create a user into db
        @user  = User.create!(rival_id: @rival, nick: @nick, title: @title, last_at: @last_at, location: @location, \
                              game_center: @game_center, tune_num: @tune_num, fc_num: @fc_num, exc_num: @exc_num)
    end
  end

  #start to parse the score
  def crawl
    cnt = 0
    rows = @page.search("//table/tr")
    rows.each do |row|
      cnt = cnt + 1
      data = row.search("td")
      if cnt > 2
        song_url = "http://p.eagate.573.jp" + data.search('a/@href').text.strip
        /mid=(.*)/ =~ song_url
        mid = Regexp.last_match[1].to_s.strip
        song_name = data.search('a').text.strip
        ext = row.search('td[5]').text.strip
        adv = row.search('td[4]').text.strip
        bas = row.search('td[3]').text.strip

        if ext != '-'
          @ext_total = @ext_total + ext.to_i
          @ext_num = @ext_num + 1
        end

        if adv != '-'
          @adv_total = @adv_total + adv.to_i
          @adv_num = @adv_num + 1
        end

        if bas != '-'
          @bas_total = @bas_total + bas.to_i
          @bas_num = @bas_num + 1
        end

        #update song's scores
        if song = @user.songs.find_by(mid: mid)
          song.bas_score = bas
          song.adv_score = adv
          song.ext_score = ext
          song.save
        else
          # get song's level
          @test = @agent.get song_url
          seqs = @test.search("div.seq")
          tmp = seqs[0].search("tr.head").text.strip
          /LEVEL : (.*)/ =~ tmp
          bas_lv = Regexp.last_match[1].strip
          tmp = seqs[1].search("tr.head").text.strip
          /LEVEL : (.*)/ =~ tmp
          adv_lv = Regexp.last_match[1].strip
          tmp = seqs[2].search("tr.head").text.strip
          /LEVEL : (.*)/ =~ tmp
          ext_lv = Regexp.last_match[1].strip

          @user.songs.create!(name: song_name, bas_score: bas, adv_score: adv, ext_score: ext, bas_lv: bas_lv, adv_lv: adv_lv, ext_lv: ext_lv, mid: mid)
        end

        puts "#{ song_name } ".colorize(:cyan) + "紅譜：#{ ext } ".colorize(:red) + "黃譜：#{ adv } ".colorize(:yellow) + "綠譜：#{ bas }".colorize(:green)
      end
    end
  end

  #sort 0-1 照名稱排 2-3 照綠譜排 4-5 照黃譜排 6-7 照紅譜排
  #page 頁數
  def start
    for i in 1..12
      @page = @agent.get "http://p.eagate.573.jp/game/jubeat/prop/p/playdata/music.html?rival_id=#{ @rival }&sort=7&page=#{ i }"
      crawl
    end
  end

  #print basic, advance, extreme score
  def printscore
    puts "綠譜平均：#{ @bas_total * 1.0 / @bas_num }".colorize(:light_green)
    puts "黃譜平均：#{ @adv_total * 1.0 / @adv_num }".colorize(:light_yellow)
    puts "紅譜平均：#{ @ext_total * 1.0 / @ext_num }".colorize(:light_red)
    puts "全譜面平均：#{ (@bas_total + @adv_total + @ext_total) * 1.0 / (@bas_num + @adv_num + @ext_num) }".colorize(:light_white)
  end
end

