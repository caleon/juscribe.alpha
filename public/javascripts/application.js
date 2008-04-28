// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var Browser = Class.create();
Browser.prototype = {
	domEl: '',
	previewPane: null,
	lastClicked: new Hash(),
	
	initialize: function(domEl, previewPane){
		this.domEl = domEl;
		this.previewPane = previewPane;
	},
	setActiveLink: function(el, lvl){
		Element.addClassName(el, 'active')
		if (this.lastClicked.get(lvl) && this.lastClicked.get(lvl) != el) {
			Element.removeClassName(this.lastClicked.get(lvl), 'active');
		}
		this.lastClicked.set(lvl, el);
		$(this.previewPane + '-inner').innerHTML = 'Nothing selected';
	}
};

// Classes method: Ruby iterates through each comment's references and adds dom class "reference-12".
// 								 Javascript searches for class and displays references.
//								 and those referencing this comment??
//								 Actually the above will show "children" of a particular comment. Need to show
//								 ancestors now... Well grab the class names of this comment beginning with "reference-",
//								 do a $() find on those strings and Element.show() them.
// 							FLAW: Idea is to hide the rest. Not show the selected.
//									Then on initialize, I need to build an array of all comment ids, from which I'll subtract
//									the ids grabbed from steps above, and then run Element.fade() on them.
//									Or just hide all children of parent ul.comments, then show thread...?


var CommentEngine = Class.create();
CommentEngine.prototype = {
	baseURI: '',
	prefix: '',
	domList: null,
	commentableType: null,
	commentableId: null,
	comments: [],
	activeCommentIds: [],
	hiddenCommentIds: [],
	commentAssociations: new Hash(),
	commentsIndex: new Hash(),
	
	// Actually, ideally I want new CommentEngine(this) on the article or something...
	initialize: function(baseURI, indexFile, commentsList, prefix){
		this.baseURI = baseURI;
		this.prefix = prefix;
		this.commentAssociations = new Hash();
		this.commentsIndex = new Hash();
				
		new Ajax.Request(baseURI + indexFile, {
			method: 'get',
			onSuccess: this.createComments.bind(this)
		});

		this.domList = $(commentsList);	
	},
	
	createComments: function(response){
		var xmlDoc = response.responseXML;
		var commentable = xmlDoc.getElementsByTagName('commentable')[0];
		
		this.commentableType = commentable.getAttribute('type');
		this.commentableId = commentable.getElementsByTagName('id')[0].firstChild.nodeValue;
		
		var commentsNode = xmlDoc.getElementsByTagName('comments')[0];
		var commentNodes = commentsNode.getElementsByTagName('comment');
		for(var i = 0; i < commentNodes.length; i++){
			var commentNode = commentNodes[i];
			var commentId = commentNode.getAttribute('id');
			var references = commentNode.getElementsByTagName('reference_id');
			var referenceIds = new Array;
			for(var j = 0; j < references.length; j++){
				var reference = references[j];
				referenceIds.push(reference.firstChild.nodeValue);
			};
			var comment = new Comment(commentId, referenceIds);
			this.indexReference(comment.id, comment.referenceIds);
			this.comments.push(comment);
		};
	},
	indexReference: function(commentId, referenceIds){
		if(this.commentAssociations.get(commentId)){
			this.commentAssociations.set(commentId, this.commentAssociations.get(commentId).concat(referenceIds).uniq());
		} else {
			this.commentAssociations.set(commentId, referenceIds);
		};
		for(var i = 0; i < referenceIds.length; i++){
			if(referenceIds[i]){
				this.inverseIndex(referenceIds[i], commentId);
			}
		}
	},
	inverseIndex: function(referenceId, commentId){
		var referenceIds;
		if(referenceIds = this.commentAssociations.get(referenceId)){
			if(!referenceIds.include(commentId)){
				this.commentAssociations.set(referenceId, referenceIds.concat(commentId));
			};
		} else {
			this.commentAssociations.set(referenceId, [commentId]);
		}
	},
	addComment: function(commentId, referenceIds){},
	removeComment: function(commentId){},
	showThread: function(commentId){
		var thread = this.commentAssociations.get(commentId);
		var other_ids = this.comments.collect(function(com){ return com.id }).reject(function(id){ return commentId == id || thread.include(id) });
		this.hiddenCommentIds = other_ids;
		other_ids.collect(function(id){ return $('comment-' + id) }).invoke('fade');
	},
	unshowThread: function(commentId){
		this.hiddenCommentIds.collect(function(id){ return $('comment-' + id) }).invoke('appear');
		this.hiddenCommentIds = [];
	}
};

Comment = Class.create();
Comment.prototype = {
	id: null,
	referenceIds: null,
	
	initialize: function(id, referenceIds){
		this.id = id;
		if(referenceIds){
			this.referenceIds = referenceIds;
		};
	}
	
	
};