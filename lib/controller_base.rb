require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './flash'
require 'byebug'

# Require your models here


class ControllerBase

  @@protected = nil

  attr_reader :req, :res, :params

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @already_built_response = false
    @params = route_params.merge(req.params)
  end

  def already_built_response?
    @already_built_response
  end

  def redirect_to(url)
    if already_built_response?
      raise "error"
    else
      @res['Location'] = url
      @res.status = 302
      @already_built_response = true
      session.store_session(@res)
      flash.store_flash(@res)
    end
  end

  def render_content(content, content_type)
    raise "error" if already_built_response?
    @res['Content-Type'] = content_type
    @res.write(content)
    @already_built_response = true
    session.store_session(@res)
    flash.store_flash(@res)
  end

  def render(template_name)
    controller = self.class.to_s.underscore
    path = "./views/#{controller}/#{template_name}.html.erb"
    template = ERB.new(File.read(path)).result(binding)
    render_content(template, 'text/html')
  end

  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  #CSRF methods

  def form_authenticity_token
    if @token && @token != ""
      @token
    else
      @token = SecureRandom::urlsafe_base64
      attributes = {}
      attributes[:path] = '/'
      attributes[:value] = @token
      @res.set_cookie('authenticity_token', attributes)
      @token
    end
  end

  def check_authenticity_token(token)
    unless token == @params["authenticity_token"] && !token.nil?
      raise "Invalid authenticity token"
    end
  end

  def self.protect_from_forgery
    @@protected = true
  end

  def invoke_action(name)
    if @req.post? && @@protected
      check_authenticity_token(req.cookies['authenticity_token'])
    end
    self.send(name)
    render(name) unless already_built_response?
  end
end
