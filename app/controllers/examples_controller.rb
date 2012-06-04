class ExamplesController < ApplicationController
  def selectable_rows
    @todos = Todo.order(:created_at)
  end
end
