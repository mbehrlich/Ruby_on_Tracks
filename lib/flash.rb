require 'json'

class Flash

  def initialize(req)
    @now = {}
    if req.cookies['_rails_lite_app_flash']
      @flash = JSON.parse(req.cookies['_rails_lite_app_flash'])
      @new = false
    else
      @flash = {}
      @new = true
    end
  end

  def [](key)
    flash = @now.merge(@flash)
    flash[key]
  end

  def []=(key, val)
    @flash[key] = val
    @new = true
  end

  def now
    @now
  end

  def store_flash(res)
    if @new == false
      res.delete_cookie('_rails_lite_app_flash')
    else
      attributes = {}
      attributes[:path] = '/'
      attributes[:value] = @flash.to_json
      res.set_cookie('_rails_lite_app_flash', attributes)
    end
  end


end
