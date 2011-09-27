require 'test_helper'

module Rails3JQueryAutocomplete
  class Rails3JQueryAutocompleteTest < ActionController::TestCase

    class ::User
      def id ; 1 end
    end
    class ::Movie ; end

    class ActorsController < ActionController::Base
      def current_user
        @user ||= User.new
      end
      autocomplete(:movie, :name, { :display_value => :name }) do |items|
        items.where("user_id = :user_id", :user_id => current_user.id)
      end
    end

    context '#autocomplete_object_method' do
      setup do
        @controller = ActorsController.new
        @items = {}
        @options = { :display_value => :name }
      end

      should 'respond to the action' do
        assert_respond_to @controller, :autocomplete_movie_name
      end

      should 'render the JSON items' do
        mock(@controller).get_autocomplete_items({
          :model => Movie, :method => :name, :options => @options, :term => "query"
        }) { @items }

        mock(@controller).json_for_autocomplete(@items, :name, nil)
        mock(@items).where("user_id = :user_id", :user_id => @controller.current_user.id) { @items }
        get :autocomplete_movie_name, :term => 'query'
      end

      context 'no term is specified' do
        should "render an empty hash" do
          mock(@controller).json_for_autocomplete({}, :name, nil)
          get :autocomplete_movie_name
        end
      end
    end
  end
end
