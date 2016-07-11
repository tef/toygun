module Toygun
  class AdminApi < Sinatra::Base
    # /Resource?uuid= ...
    get "/:resource/" do
      # return dataset / or
      # return instance
    end

    get "/:resource/:task" do
      # return task
    end

    post "/:resource/:task" do
      # start task
    end
  end
end
