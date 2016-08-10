require 'erb'

class ShowExceptions

  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      app.call(env)
    rescue Exception => error
      render_exception(error)
    end
  end

  private

  def render_exception(e)
    path = "./lib/templates/rescue.html.erb"
    @error = e.message
    template = ERB.new(File.read(path)).result(binding)
    ['500', {'Content-type' => 'text/html'}, [@error, template]]
  end

end
