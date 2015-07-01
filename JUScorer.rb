# encoding: utf-8
require 'rubygems'
require 'mechanize'
require 'sqlite3'
require './config/config.rb'

class JUScorer
  def initialize
    @ext_total = 0
    @adv_total = 0
    @bas_total = 0
    @ext_num = 0
    @adv_num = 0
    @bas_num = 0
    @rival = 60930007178425
    login
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

  #start to parse the score
  def crawl
    cnt = 0
    rows = @page.search("//table/tr")
    rows.each do |row|
      cnt = cnt + 1
      data = row.search("td")
      if cnt > 2
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

        p "#{data.search('a').text.strip} " \
        "紅譜：#{ext} " \
        "黃譜：#{adv} " \
        "綠譜：#{bas}"
      end
    end
  end

  #sort 0-1 照名稱排 2-3 照綠譜排 4-5 照黃譜排 6-7 照紅譜排
  #page 頁數
  def start
    for i in 1..11
      @page = @agent.get "http://p.eagate.573.jp/game/jubeat/prop/p/playdata/music.html?rival_id=#{ @rival }&sort=7&page=#{ i }"
      crawl
    end
  end

  #print basic, advance, extreme score
  def printscore
    p "綠譜平均：#{ @bas_total * 1.0 / @bas_num}"
    p "黃譜平均：#{ @adv_total * 1.0 / @adv_num}"
    p "紅譜平均：#{ @ext_total * 1.0 / @ext_num}"
    p "全譜面平均：#{ (@bas_total + @adv_total + @ext_total) * 1.0 / (@bas_num + @adv_num + @ext_num) }"
  end
end
