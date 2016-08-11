require_relative '../lib/controller_base'

class CatsController < ControllerBase

  def index
    @cats = Cat.all
  end

  def new
    @cat = Cat.new
  end

  def create
    @cat = Cat.new(@params["cat"])
    @cat.save
    redirect_to '/'
  end

end
