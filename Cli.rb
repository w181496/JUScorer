require './JUScorer.rb'

class Cli

  def initialize
    @flag = true
    puts "Welcome to JUScoreer".colorize(:light_cyan)
    start
  end

  def start
    while(@flag)
      puts "=".colorize(:light_green) * 16
      puts "1) Add Score".colorize(:light_green)
      puts "2) Update Score".colorize(:light_green)
      puts "3) Compare Score".colorize(:light_green)
      puts "4) Exit".colorize(:light_green)
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
    print "Input the id of user that you want to update: ".colorize(:light_yellow)
    uid = gets.chomp.to_i
    puts "Please wait ...".colorize(:light_green)
    user_upd = User.find_by(id: uid)
    JUScorer.new(user_upd.rival_id).printscore
  end

  def compareScore
    # TODO
  end
end
