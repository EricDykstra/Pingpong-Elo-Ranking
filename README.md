Pingpong Elo Ranking
========================

Dead simple way to keep track of pingpong (or any other two player game) stats and calculate Elo (http://en.wikipedia.org/wiki/Elo_rating_system)

If there's a better version of this somewhere, let me know, otherwise feel free to improve and fork or pull request or whatever.

**Installation**
Create a Postgres database called "pingpong" with a single table, "games".

**Use**
To record a game...
ruby ping.rb [winner's name] [loser's name]

To see a leaderboard...
ruby ping.rb leaderboard
