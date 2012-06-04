require 'spec_helper'

describe ExamplesController do

  describe "GET 'selectable_rows'" do
    it "returns http success" do
      get 'selectable_rows'
      response.should be_success
    end
  end

end
