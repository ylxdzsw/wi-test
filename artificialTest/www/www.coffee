`Corpus = new Mongo.Collection("corpus")`

if Meteor.isClient
	Session.set 'loading', true

	Meteor.subscribe 'Corpus', ->
		do init

	Template.metadata.helpers
		"username": -> Session.get 'username'

	Template.metadata.events
		"change #username": (e) ->
			Session.setPersistent "username", e.target.value

	Template.verify.helpers
		"sentence": -> Session.get('current')?.sentence
		"pinyin": -> Session.get('current')?.pinyin

	Template.verify.events
		"click #reject": (e) ->
			return alert("请输入你的名字") if not Session.get 'username'
			Corpus.update Session.get('current')?._id,
				$set:
					status: "abandoned"
					checkedAt: new Date()
					checkedBy: Session.get 'username'
			do goNext
		"click #skip": (e) ->
			do goNext
		"click #submit": (e) ->
			return alert("请输入你的名字") if not Session.get 'username'
			Corpus.update Session.get('current')?._id,
				$set:
					sentence: $("#sentence").val().replace(/\s/,'')
					pinyin: $("#pinyin").val().replace(/\s/,'')
					status: "checked"
					checkedAt: new Date()
					checkedBy: Session.get 'username'
			do goNext

	Template.sidepanel.helpers
		"categories": ->
			Session.get('categories').map (x) ->
				now = Corpus.find({categories:x.id,status:"unchecked"}).count()
				name: x.name
				now: now
				total: x.total
				ratio: "#{now}/#{x.total}"
		"contributors": ->
			x = _.groupBy Corpus.find().fetch(), (x) -> x.checkedBy
			y = for k,v of x
				username: k
				contribution: v.length

			_.sortBy(y,(x)->x.contribution).reverse()

	Template.loading.helpers
		"loading": -> Session.get 'loading'

	goNext = ->
		Session.set 'current', _.sample Corpus.find({status:"unchecked"}).fetch()
	
	init = do ->
		initialized = false
		->
			return if initialized
			initialized = true
			
			Session.set 'categories', Session.get('categories').map (x) -> x.total = Corpus.find({category:x.id}).count(); x # Stupid Mongodb has no GroupBy
			Session.set 'loading', false
			do goNext

	Session.set 'categories', [ # use session to store this to enable reactive refreshing
		{id:"1",name:"自然科学"},
		{id:"2",name:"人文社科"},
		{id:"3",name:"正式公文"},
		{id:"4",name:"娱乐新闻"},
		{id:"5",name:"网络小说"},
		{id:"6",name:"文学作品"}
	]

if Meteor.isServer
	Meteor.publish 'Corpus', -> Corpus.find()
	