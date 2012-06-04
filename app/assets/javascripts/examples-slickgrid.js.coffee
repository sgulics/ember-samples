#= require 'jquery.event.drag-2.0.min'
#= require 'slickgrid/slick.core'
#= require 'slickgrid/slick.dataview'
#= require 'slickgrid/slick.formatters'
#= require 'slickgrid/slick.editors'
#= require 'slickgrid/plugins/slick.cellselectionmodel'
#= require 'slickgrid/plugins/slick.cellrangedecorator'
#= require 'slickgrid/plugins/slick.cellrangeselector'
#= require 'slickgrid/controls/slick.pager'
#= require 'slickgrid/slick.grid'

window.Todos = Ember.Application.create()

Ember.SlickGridDataView = Ember.Object.extend
  defaultPageSize: 10
  pageSize: 0
  totalPages: 0
  totalRows: 0
  pageNum: 0
  items: []
  results: {}
  sortInfo: []
  didResultsChange: (->
    if @results.entries
      @set "items", @results.entries
      @set "pageSize", @results.perPage
      @set "totalPages", @results.totalPages
      @set "totalRows", @results.totalEntries
      @set "pageNum",@results.currentPage
      @onPagingInfoChanged.notify(@getPagingInfo(), null, @)
  ).observes("results")

  onPagingInfoChanged: new Slick.Event()
  onRowCountChanged: new Slick.Event()
  onRowsChanged: new Slick.Event()
  getPagingInfo: ->
    #console.log @
    pageSize: @pageSize
    totalPages: @totalPages
    totalRows: @totalRows
    pageNum: @pageNum-1
  setRefreshHints: (ops)->
    # implement
  setPagingOptions: (args)->
    @set "pageNum", if args.pageNum? then args.pageNum+1 else 1
    @set "pageSize", if args.pageSize? then args.pageSize else @defaultPageSize
    @refresh()
    @onPagingInfoChanged.notify(@getPagingInfo(), null, @)
  setSortCols: (sortCols) ->
    @set "sortInfo", []
    @set "pageNum", 1
    sortCols.forEach (col)=>
      @sortInfo.push
        field: col.sortCol.field
        asc: col.sortAsc
    @refresh()
  # instances of this class will need to implement this method
  refresh: ->
    #console.log "Ember.SlickGridDataView: Please implement the refresh() method"
  
  dataForAjax: ->
    page: if @pageNum > 0 then @pageNum else 1
    per_page: if @pageSize > 0 then @pageSize else @defaultPageSize
    sort: @sortInfo 
    filters: @filters
  setFilters: (filters)->
    #console.log filters
    @set "pageNum", 1
    @filters = filters

Todos.dataView = Ember.SlickGridDataView.create
  refresh: (options)->
    $.ajax(
      url: '/todos'
      dataType: 'json'
      data: @dataForAjax()
      type: 'GET'
    ).done (json) =>
      @set "results", json
  




      

Todos.GridContainerView = Ember.View.extend

  contentBinding: 'Todos.dataView.items'
  onDataLoading: new Slick.Event()
  onDataLoaded: new Slick.Event()
  
  didContentChange: (->
    if @grid
      @grid.setData(@content)
      @grid.invalidate() 
  ).observes("content")
  
  didInsertElement: ->
    columns = [
        id: "id"
        name: "ID"
        field: "id"
        width: 40
        sortable: true
      ,
        id: "title"
        name: "Title"
        field: "title"
        width: 400
        editor: Slick.Editors.Text
        sortable: true
    ]

    options = 
      #rowHeight: 64
      #forceFitColumns: true
      #editable: false
      #enableAddRow: false
      enableCellNavigation: true
      autoHeight: true
      editable: true
      enableAddRow: true
      multiColumnSort: true
      showHeaderRow: true
      headerRowHeight: 40

    columnFilters = {}
    
    @grid = new Slick.Grid("#grid", @content, columns, options)
    @grid.setSelectionModel(new Slick.CellSelectionModel())
    @grid.onSort.subscribe (e, args) ->
      Todos.dataView.setSortCols args.sortCols

    updateHeaderRow = ()=>
      for column in columns
        header = @grid.getHeaderRowColumn column.id
        $(header).empty()
        $("<input type='text'>")
            .data("columnId", column.id)
            .val(columnFilters[column.id])
            .appendTo(header)


    @grid.onColumnsReordered.subscribe (e, args)->
      updateHeaderRow() 

    #@grid.onCellChange.subscribe (args) ->
    #  console.log arguments
    pager = new Slick.Controls.Pager(Todos.dataView, @grid, $("#pager"));

    Todos.dataView.onRowCountChanged.subscribe (e, args)->
      #grid.updateRowCount();
      #grid.render();
    Todos.dataView.onRowsChanged.subscribe (e, args)->
      #console.log "onRowCountChanged"
      #console.log args
      #grid.invalidateRows(args.rows);
      #grid.render();
    $(@grid.getHeaderRow()).delegate ":input", "change keyup", (e)->
      columnFilters[$(@).data("columnId")] = $.trim($(@).val())
      Todos.dataView.setFilters(columnFilters)
      if e.keyCode == 13
        Todos.dataView.refresh()

    updateHeaderRow()
    #@grid.onViewportChanged.subscribe (e, args)=>
    #  console.log "onViewportChanged"
    #@grid.onSort.subscribe (e, args) =>
    #  console.log "onSort"

    #@onDataLoading.subscribe =>
    #  console.log "onDataLoading"

    #@onDataLoaded.subscribe =>
    #  console.log "onDataLoaded"

    #Todos.todosController.load()

Todos.dataView.refresh()
