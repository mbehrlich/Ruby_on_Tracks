def run_routes(router)
  router.draw do
    # Write routes in the following fashion
    #
    # get Regexp.new("^/dogs/(?<id>\\d+)$"), DogsController, :show
    #
    # first argument is method
    # second argument is a Regexp that matches the path of the request.
    # The example captures the id of a specific dog
    # The third argument is the controller, the file that contains the
    # controller will need to be required in the server.rb file.
    # the fourth argument will be the action, the name of the method
    # in your controller.
    

  end
end
