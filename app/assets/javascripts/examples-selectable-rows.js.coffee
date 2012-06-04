#= require templates/selectable_rows/list
#= require templates/selectable_rows/show


window.Todos = Ember.Application.create
  rootElement: "#app"
  keypress: (event)->
    #console.log event

Todos.Todo = Em.Object.extend
  title: null
  done: false
  selected: false
  toggleSelect: ->
    if @selected
      @set("selected", false)
    else
      @set("selected", true)


$(document).keyup (e)->
  if e.keyCode == 27
    Todos.rowSelectionModel.resetSelected()


Todos.todosController = Em.ArrayProxy.create
  content: []

  initializeTodos: (array)-> 
    array.forEach (t)=>
      @pushObject Todos.Todo.create(t)
  
  resetSelected: ->
    @selected().setEach("selected", false)
    
  selected: ->
    @content.filterProperty("selected", true)

  select: (index)-> 
    @content[index].set("selected", true)

  selectRange: (start,end)->
    #console.log "selectRange #{start} #{end}"
    @select num for num in [start..end]

  toggleSelect: (index)->
    @content[index].toggleSelect()

  selectTodo: (index, event)->
    Todos.rowSelectionModel.handleSelection(index, event)

Todos.rowSelectionModel = Em.Object.create
  last: -1
  resetSelected: ->
    @last = -1
    Todos.todosController.resetSelected()

  handleSelection: (index, event)->
    #console.log event
    if event.shiftKey
      Todos.todosController.resetSelected()
      if @last >= 0
        start = Math.min(index, @last)
        end = Math.max(index, @last)
        #@last = index
        Todos.todosController.selectRange(start, end)
      else
        @last = index
        Todos.todosController.select(index)
    else
      
      if event.ctrlKey || event.metaKey
        if !Todos.todosController.content[index].selected
          @last = index
      else
        @last = index
        Todos.todosController.resetSelected()
      Todos.todosController.toggleSelect(index)





Todos.ListTodosView = Ember.View.extend
  templateName: 'selectable_rows/list'
  todosBinding: 'Todos.todosController'

  

Todos.ShowTodoView = Ember.View.extend
  templateName: 'selectable_rows/show'
  tagName:      'tr'

  selectedDidChange: (->
    if @todo.selected
      @$().addClass('selected')
    else
      @$().removeClass('selected')
  ).observes("todo.selected")

  click: (event)->
    Todos.todosController.selectTodo(@getPath('_parentView.contentIndex'), event)

  
  didInsertElement: ->
    @_super()
    #console.log "didInsertElement"
    @$().css("cursor", "pointer")
    @$().hover( 
      =>
        @$().addClass('hover')
      , 
      =>
        @$().removeClass('hover')
    )

  
  