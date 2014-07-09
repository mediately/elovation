class ResultsController < ApplicationController
  before_action :set_game
  skip_before_action :verify_authenticity_token, only: :slack

  def create
    response = ResultService.create(@game, params[:result])

    if response.success?
      redirect_to game_path(@game)
    else
      @result = response.result
      render :new
    end
  end

  def slack
    winner, loser = params[:text].split(':').map{ |name|
      Player.where('name ilike ?', name).first
    }

    result = {
      teams: {
        '0' => {
          players: winner.id,
          relation: 'defeats'
        },
        '1' => {
          players: loser.id
        }
      }
    }

    if ResultService.create(@game, result).success?
      render plain: "Congratulations #{winner.name}!"
    else
      head :bad_request
    end
  end

  def destroy
    result = @game.results.find_by_id(params[:id])

    response = ResultService.destroy(result)

    redirect_to :back
  end

  def new
    @result = Result.new
    (@game.max_number_of_teams || 20).times{|i| @result.teams.build rank: i}
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end
end
