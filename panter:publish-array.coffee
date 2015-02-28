DEBUG = off

Meteor.publishArray = (options) ->
	{name, collection, data, refreshTime, refreshHandle} = options
	subscriptions = {}
	
	if refreshHandle?
		refreshHandle.refresh = ->
			if DEBUG then console.log "manually referesh #{name}"
			for id, subscription of subscriptions
				subscription.refresh()

	Meteor.publish name, (params) ->
		pub = @
		ids = {} # stores the ids of the last result
		refreshTimeoutHandle = null
		hasStopped = false

		refresh = ->
			if DEBUG then console.log "refreshing #{name}"
			start = new Date().getTime()
			currentIds = {} # stores the id of the docs of this refresh call
			try
				results = data.call pub, params
			catch error
				console.log error
				results = []
			if results?
				for result in results
					id = result._id
					currentIds[id] = true # mimic set
					#check if this is a new item
					unless ids[id]?
						#its new:
						ids[id] = true # mimic set
						pub.added collection, id, result
					else
						#its an already known item, publish it as a change:
						pub.changed collection, id, result
				# check the items, that are no longer in the result:
				for id of ids
					unless currentIds[id]?
						pub.removed collection, id
						delete ids[id]
			end = new Date().getTime()
			if DEBUG then console.log "refreshed #{name}, took #{(end-start)/1000}"

			pub.ready()

		autoRefresh = ->
			refresh()
			if refreshTime? and not hasStopped
				refreshTimeoutHandle = Meteor.setTimeout autoRefresh, refreshTime

		Meteor.defer autoRefresh

		# attach a handle
		subscriptions[pub._subscriptionId] = 
			refresh: refresh

		@onStop =>
			if DEBUG then console.log "stopping #{name}"
			hasStopped = yes
			if refreshTimeoutHandle?
				Meteor.clearTimeout refreshTimeoutHandle
			delete subscriptions[pub._subscriptionId]

