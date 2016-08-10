class Static

  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    res = Rack::Response.new
    if req.path.match(/^\/public/)
      if File.exist?('.' + req.path)
        file = File.read('.' + req.path)
        extension = req.path.split('.')[1]
        mime_types = {
          'gif' => 'image/gif',
          'jpg' => 'image/jpeg',
          'jpeg' => 'image/jpeg',
          'png' => 'image/png',
          'js' => 'text/javascript',
          'css' => 'text/css',
          'txt' => 'text/plain'
        }
        content_type = mime_types[extension]
        if content_type
          res['Content-Type'] = content_type
        end
        res.write(file)
        res.finish
      else
        res.status = 404
        res.write("404 File not found")
        res.finish
      end
    else
      app.call(env)
    end
  end

end
