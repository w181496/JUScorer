# JUScorer

## What is this
It is a crawler for the music game `Jubeat prop`

## How to use
Install Ruby, RubyGems, sqlite3, nokogiri, mechanize, colorize.

`$ gem install nokogiri`

`$ gem install mechanize`

`$ gem install colorize`

copy the `config/config.sample.rb` to `config/config.rb`

then open it, fill your 573's website username and password.

and then, open the `JUScorer.rb`, modify the value of '@rival' to your own rival id.

Now, you can run `$ ruby main.rb` to get your songs' scores!

![img](https://github.com/w181496/JUScorer/blob/master/image.png)
