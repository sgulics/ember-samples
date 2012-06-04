#= require ember-resource


window.Typeahead = Ember.Application.create()


#Typeahead.Artist = Ember.Resource.extend
#  selected: false
#  resourceUrl:        '/artists',
#  resourceName:       'artist',
#  resourceProperties: ['name'],

Typeahead.Album = Ember.Resource.define
  url:        '/albums',
  schema: 
    id: Number
    name: String
    artist_id: Number


Typeahead.Artist = Ember.Resource.define
  selected: false
  url:        '/artists',
  schema: 
    id: Number
    name: String
    albums: 
      type: Ember.ResourceCollection
      itemType: Typeahead.Album
      nested: true
      #url: '/artists/%@/albums'

Typeahead.artistController = Ember.ResourceCollection.create
  editMode: false
  artist: null
  find: (id) ->
    artist = Typeahead.Artist.create(id:id)
    artist.fetch() #content no longer works
    @set "artist", artist
  
  
Typeahead.searchArtistsController = Ember.ResourceCollection.create
  searchQuery: ""
  #resourceType: Typeahead.Artist
  content: null
  type: Typeahead.Artist
  searchQueryObserver: (->
    @searchArtists @searchQuery unless @exactMatchFound()
  ).observes("searchQuery")

  resolveUrl: ->
    "/artists?search=#{@searchQuery}"

  exactMatchFound: ->
    return false unless @get("content")
    @get("content").find (item) =>
      item.get("name") == @searchQuery
  searchArtists: (query) ->
    return if query.length == 0
    @set("resourceState",  Ember.Resource.Lifecycle.UNFETCHED) # clears cache
    @deferedFetch = null
    @fetch()
    

  Typeahead.SearchArtistView = Ember.TextField.extend
    valueBinding: 'Typeahead.searchArtistsController.searchQuery'
    artistsBinding: 'Typeahead.searchArtistsController.content'
    attributeBindings: ['data-provide','data-source','autofocus']    
    
    didvalueChange: (->
      
    ).observes("value")

    didInsertElement: ->
      @_super()
      @$().autocomplete(
        source: []
        autoFocus: true
        select: (event, ui) =>
          #console.log ui.item.id
          #console.log ui.item.value
          Typeahead.artistController.find ui.item.id
      ).focus()
      
      
    artistsObserver: (->
      
      names = @artists.map (item)->
        label: item.get("name")
        value: item.get("name")
        id: item.get("id")
      
      @$().autocomplete("option", "source", names).autocomplete("search")
    ).observes("artists.isLoaded")

  Typeahead.ArtistView = Ember.View.extend
    contentBinding: 'Typeahead.artistController.artist'
    editModeBinding: 'Typeahead.artistController.editMode'
    editModeDidChange: (->
      if @editMode
        @$().hide()
      else
        @$().show()
      ).observes("editMode")
    edit: (event) ->
      @set("editMode", true)
    didInsertElement: ->
      @$().hide()
    didContentChange: (->
      @$().show()
    ).observes("content")
      

  Typeahead.EditArtistView = Ember.View.extend
    tagName: 'form'
    contentBinding: 'Typeahead.artistController.artist'
    editModeBinding: 'Typeahead.artistController.editMode'
    attributeBindings: ['style']

    didInsertElement: ->
      @_super();
      @$('input:first').focus();
    


    editModeDidChange: (->
      if @editMode
        @$().show()
      else
        @$().hide()
      ).observes("editMode")

    cancel: (event) ->
      @set("editMode", false)
      
    submit: (event) ->
      event.preventDefault()
      @content.save()
        .fail (e)->
          if e.status = 422
            responseErrors = $.parseJSON(e.responseText)
            msgs = []
            for field, errors of responseErrors
              for e in errors
                msgs.push("#{field} #{e}")
            alert msgs.join("\n")
          else
            alert "Error Saving Artist"
          
        .done =>
          @set("editMode", false)






