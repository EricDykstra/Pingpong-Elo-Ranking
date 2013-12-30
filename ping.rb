require 'pg'
require 'active_record'
require 'uri'
require 'elo'

db = URI.parse(ENV['DATABASE_URL'] || "postgres://localhost/pingpong")
ActiveRecord::Base.establish_connection(
  :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
  :host     => db.host,
  :port     => db.port,
  :username => db.user,
  :password => db.password,
  :database => 'pingpong',
  :encoding => 'utf8',
  :pool     => ENV['DB_POOL'] || 5,
  :reaping_frequency => ENV['DB_REAP_FREQ'] || 10
)

class Game < ActiveRecord::Base
end

class Stats
  def self.leaderboard(players)
    players.sort_by{|k,v| v.rating }.reverse.each.with_index do |p,i|
      puts "#{i}. #{p[0]} has a rating of #{p[1].rating} after #{p[1].games.count} games"
    end
  end
end

players = Hash.new(0)
(Game.pluck("DISTINCT winner") + Game.pluck("DISTINCT loser")).map do |name|
  player_name = Elo::Player.new
  players[name] = player_name
end
Game.all.each do |g|
  players[g.winner].wins_from(players[g.loser])
end

if ARGV.length == 1
  Stats.send(ARGV[0],players)

else


  winner, loser = ARGV.map(&:downcase)
  if players[winner] == 0
    player_winner = Elo::Player.new
    players[winner] = player_winner
  end
  if players[loser] == 0
    player_loser = Elo::Player.new
    players[loser] = player_loser
  end

  Game.create(winner: winner, loser: loser, date: Date.today)
  players[winner].wins_from(players[loser])

  puts "#{winner} has a rating of #{players[winner].rating} after #{players[winner].games.count} games"
  puts "#{loser} has a rating of #{players[loser].rating} after #{players[loser].games.count} games"

end

