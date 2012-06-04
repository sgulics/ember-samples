class TodosController < ApplicationController

   respond_to :json

  def index
    per_page = params[:per_page] || 10
    order = ["id"]
    if params[:sort]
      sorts, order = params[:sort].to_hash.values, []
      sorts.each do |col|
        order << "#{col["field"]} #{col["asc"] == "true" ? "asc" : "desc" }"
      end
    end
    
    results = Todo.filter(params[:filters]).order(order.join(",")).paginate(:page => params[:page], :per_page => per_page)

    respond_with({
      :entries      => results.to_a,
      :currentPage  => results.current_page,
      :perPage      => results.per_page,
      :totalEntries => results.total_entries,
      :totalPages   => results.total_pages

      })
  end

  private
  def current_user;end
end
