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
      else
        test
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
    # ===========
    # TODO: type1
    # ===========
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
      puts "(1) By level (2) By difficulty".colorize(:light_green)
      print "Select type: ".colorize(:light_yellow)
      type = gets.chomp.to_i

      lv = 0
      diff = 0
      if type == 1
        puts "(1) 1 (2) 2 (3) 3 (4) 4 (5) 5 (6) 6 (7) 7 (8) 8 (9) 9 (10) 10".colorize(:light_green)
        print "Select level: ".colorize(:light_yellow)
        lv = gets.chomp.to_i
      elsif type == 2
        puts "(1) basic (2) advance (3) extreme".colorize(:light_green)
        print "Select difficulty: ".colorize(:light_yellow)
        diff = gets.chomp.to_i
      end
      puts "Please wait ...".colorize(:light_green)

      table = []
      idx = 0

      # 以等級做比較
      if type == 1
        song1 = user1.songs.where('bas_lv = ? OR adv_lv = ? OR ext_lv = ?', lv, lv, lv)

        song1.each do |song|
          cmp_score = user2.songs.find_by(mid: song.mid)
          if song.bas_lv == lv
            score = song.bas_score
            if cmp_score
              cmp_score = cmp_score.bas_score
            end
            if cmp_score && cmp_score > 0 && score > 0
              table[idx] = [song.name, score, cmp_score, score - cmp_score]
              idx += 1
            end
          elsif song.adv_lv == lv
            score = song.adv_score
            if cmp_score
              cmp_score = cmp_score.adv_score
            end
            if cmp_score && cmp_score > 0 && score > 0
              table[idx] = [song.name, score, cmp_score, score - cmp_score]
              idx += 1
            end
          elsif song.ext_lv == lv
            score = song.ext_score
            if cmp_score
              cmp_score = cmp_score.ext_score
            end
            if cmp_score && cmp_score > 0 && score > 0
              table[idx] = [song.name, score, cmp_score, score - cmp_score]
              idx += 1
            end
          end
        end
      # 以紅黃綠譜作比較
      elsif type == 2
        song1 = user1.songs.order('name')

        song1.each do |song|
          if diff == 1
            score = song.bas_score
            if cmp_score = user2.songs.find_by(mid: song.mid)
              cmp_score = cmp_score.bas_score
            end
          elsif diff == 2
            score = song.adv_score
            if cmp_score = user2.songs.find_by(mid: song.mid)
              cmp_score = cmp_score.adv_score
            end
          elsif diff == 3
            score = song.ext_score
            if cmp_score = user2.songs.find_by(mid: song.mid)
              cmp_score = cmp_score.ext_score
            end
          end

          if !cmp_score
            #table[idx] = [song.name, score, '0', ' - ']
          elsif cmp_score == 0 || score == 0
            #table[idx] = [song.name, score, cmp_score, ' - ']
          else
            table[idx] = [song.name, score, cmp_score, score - cmp_score]
            idx += 1
          end
          #idx += 1
        end
      end

      puts "曲名 #{user1.nick} #{user2.nick} 差距".colorize(:light_green)
      puts "=".colorize(:light_green) * 25

      #sort table by score
      table.sort! {|x,y| x[3].to_i <=> y[3].to_i}

      table.each do |row|
        print "#{row[0]}".colorize(:light_yellow)
        print " #{row[1]} #{row[2]}"
        if row[3].to_i > 0
          puts " +#{row[3]}".colorize(:light_cyan)
        else
          puts " #{row[3]}".colorize(:light_red)
        end
      end

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

