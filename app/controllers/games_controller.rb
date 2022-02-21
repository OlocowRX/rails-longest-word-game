require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
  end

  def score
    @letters = params[:letters].split(' ')
    @guess = params[:word].upcase
    @start_time = Time.parse(params[:start_time])
    @end_time = Time.now
    # ------------------------------------|
    @time_taken = @end_time - @start_time
    @points = points(@guess, @time_taken)
    # ------------------------------------|
    compute_score(@guess, @letters, @points)
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def english_word(word)
    response = URI.open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    json['found']
  end

  def points(guess, time_taken)
    time_taken > 60.0 ? 0 : guess.size * (1.0 - time_taken / 60.0)
  end

  def compute_score(guess, grid, points)
    if included?(guess, grid)
      if english_word(guess)
        @result = "Congratulations! #{guess} is a valid English word! And your score was #{points}"
      else
        @result = "Sorry but #{guess} does not seem to be a valid English word..."
      end
    else
      @result = "Sorry but #{guess}, can't be build out of #{grid.join(',')}"
    end
  end
end
