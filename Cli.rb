require './JUScorer.rb'

class Cli

  def initialize
    @flag = true
    puts "Welcome to JUScorer".colorize(:light_cyan)
    start
  end

  def start
    while(@flag)
      puts "=".colorize(:light_green) * 16
      puts "1) Add Score".colorize(:light_green)
      puts "2) Update Score".colorize(:light_green)
      puts "3) Compare Score".colorize(:light_green)
      puts "4) Player Information".colorize(:light_green)
      puts "5) Delete Data".colorize(:light_green)
      puts "6) Exit".colorize(:light_green)
      puts "=".colorize(:light_green) * 16
      print "Select one operation that you want to do: ".colorize(:light_yellow)
      op = gets.to_i # input operatiin

      if op == 1
        addScore
      elsif op == 2
        updateScore
      elsif op == 3
        compareScore
      elsif op == 4
        playerInfo
      elsif op == 5
        deleteData
      elsif op == 6
        @flag = false
      end

    end
  end

  def addScore
    print "Input the rival id that you want to add: ".colorize(:light_yellow)
    riv = gets.chomp
    puts "Please wait ...".colorize(:light_green)
    JUScorer.new(riv).printscore
  end

  def updateScore
    users = User.all
    users.each do |user|
      puts "#{user.id}) #{user.rival_id} #{user.nick} #{user.title} #{user.last_at} #{user.location} #{user.game_center}"
    end

    if users.count > 0
      print "Input the id of user that you want to update: ".colorize(:light_yellow)
      uid = gets.chomp.to_i
      puts "Please wait ...".colorize(:light_green)
      user_upd = User.find_by(id: uid)
      JUScorer.new(user_upd.rival_id).printscore
    else
      puts "No user data!".colorize(:light_red)
    end
  end

  def compareScore
    # =====
    # TODO
    # =====
    users = User.all
    users.each do |user|
      puts "#{user.id}) #{user.rival_id} #{user.nick} #{user.title} #{user.last_at} #{user.location} #{user.game_center}"
    end
    if users.count > 0
      print "Select first player to compare scores: ".colorize(:light_yellow)
      uid = gets.chomp.to_i
      user1 = User.find_by(id: uid)
      print "Select second player to compare scores: ".colorize(:light_yellow)
      uid = gets.chomp.to_i
      user2 = User.find_by(id: uid)
      puts "Please wait ...".colorize(:light_green)

    else
      puts "No user data!".colorize(:light_red)
    end
  end

  def playerInfo
    users = User.all
    users.each do |user|
      puts "#{user.id}) #{user.rival_id} #{user.nick} #{user.title} #{user.last_at} #{user.location} #{user.game_center}"
    end

    if users.count > 0
      print "Select a player: ".colorize(:light_yellow)
      uid = gets.chomp.to_i
      player = User.find_by(id: uid)
      puts "== User Info ==".colorize(:light_yellow)
      puts "rival id: #{player.rival_id}".colorize(:light_yellow)
      puts "暱稱: #{player.nick}".colorize(:light_yellow)
      puts "稱號: #{player.title}".colorize(:light_yellow)
      puts "最後遊玩時間: #{player.last_at}".colorize(:light_yellow)
      puts "地點: #{player.location} #{player.game_center}".colorize(:light_yellow)
      puts "Tune數: #{player.tune_num}".colorize(:light_yellow)
      puts "Full combo數: #{player.fc_num}".colorize(:light_yellow)
      puts "Exc數: #{player.exc_num}".colorize(:light_yellow)

      songs = player.songs
      scores = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      num = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      a = 0
      s = 0
      ss = 0
      sss = 0
      exc = 0
      songs.each do |song|
        if song.bas_score > 0
          if song.bas_score == 1000000
            exc += 1
          elsif song.bas_score >= 980000
            sss += 1
          elsif song.bas_score >= 950000
            ss += 1
          elsif song.bas_score >= 900000
            s += 1
          else
            a += 1
          end
          scores[song.bas_lv] += song.bas_score
          num[song.bas_lv] += 1
        end

        if song.adv_score > 0
          if song.adv_score == 1000000
            exc += 1
          elsif song.adv_score >= 980000
            sss += 1
          elsif song.adv_score >= 950000
            ss += 1
          elsif song.adv_score >= 900000
            s += 1
          else
            a += 1
          end
          scores[song.adv_lv] += song.adv_score
          num[song.adv_lv] += 1
        end

        if song.ext_score > 0
          if song.ext_score == 1000000
            exc += 1
          elsif song.ext_score >= 980000
            sss += 1
          elsif song.ext_score >= 950000
            ss += 1
          elsif song.ext_score >= 900000
            s += 1
          else
            a += 1
          end
          scores[song.ext_lv] += song.ext_score
          num[song.ext_lv] += 1
        end
      end

      puts "== 分數統計 ==".colorize(:light_cyan)
      (1..10).each do |i|
        if num[i] > 0
          puts "#{i}等平均： #{scores[i] / num[i]}".colorize(:light_cyan)
        else
          puts "#{i}等平均： 0".colorize(:light_cyan)
        end
      end

      puts "A:#{a} S:#{s} SS:#{ss} SSS:#{sss} EXC:#{exc}".colorize(:light_cyan)

    else
      puts "No user data!".colorize(:light_red)
    end
  end

  def deleteData
    users = User.all
    users.each do |user|
      puts "#{user.id}) #{user.rival_id} #{user.nick} #{user.title} #{user.last_at} #{user.location} #{user.game_center}"
    end

    if users.count > 0
      print "Select a player: ".colorize(:light_yellow)
      uid = gets.chomp.to_i
      player = User.find_by(id: uid)
      player.destroy
    else
      puts "No user data!".colorize(:light_red)
    end
  end
end
