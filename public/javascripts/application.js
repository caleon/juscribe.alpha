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
		};
		this.lastClicked.set(lvl, el);
		$(this.previewPane + '-inner').innerHTML = 'Nothing selected';
	}
};

Scroller = {
	yOffset: 200,
	scrollLoop: false, 
	scrollInterval: null,
	getWindowHeight: function(){
		if (document.all){
			return (document.documentElement.clientHeight) ? document.documentElement.clientHeight : document.body.clientHeight;
		} else {
			return window.innerHeight;
		}
	},
	getScrollLeft: function(){
		if (document.all) {
			return (document.documentElement.scrollLeft) ? document.documentElement.scrollLeft : document.body.scrollLeft;
		} else {
			return window.pageXOffset;
		}
	},
	getScrollTop: function(){
		if (document.all) {
			return (document.documentElement.scrollTop) ? document.documentElement.scrollTop : document.body.scrollTop;
		} else {
			return window.pageYOffset;
		}
	},
	getElementYpos: function(el){
		var y = 0;
		while(el.offsetParent){
			y += el.offsetTop
			el = el.offsetParent;
		}
		return y;
	},
	to: function(id){
		if(this.scrollLoop){
			clearInterval(this.scrollInterval);
			this.scrollLoop = false;
			this.scrollInterval = null;
		};
		var container = document.getElementById('canvas');
		var documentHeight = this.getElementYpos(container) + container.offsetHeight;
		var windowHeight = this.getWindowHeight()-this.yOffset;
		var ypos = this.getElementYpos(document.getElementById(id));
		if(ypos > documentHeight - windowHeight) ypos = documentHeight - windowHeight;
		this.scrollTo(0,ypos-this.yOffset);
	},
	scrollTo: function(x,y) {
		if(this.scrollLoop) {
			var left = this.getScrollLeft();
			var top = this.getScrollTop();
			if(Math.abs(left-x) <= 1 && Math.abs(top-y) <= 1) {
				window.scrollTo(x,y);
				clearInterval(this.scrollInterval);
				this.scrollLoop = false;
				this.scrollInterval = null;
			} else {
				window.scrollTo(left+(x-left)/2, top+(y-top)/2);
			}
		} else {
			this.scrollInterval = setInterval("Scroller.scrollTo("+x+","+y+")",100);
			this.scrollLoop = true;
		}
	}
};

var CommentEngine = Class.create();
CommentEngine.prototype = {
	baseURI: '',
	prefix: '',
	domList: null,
	commentableType: null,
	commentableId: null,
	showingThread: null,
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
		var commentNodes = this.domList.select('li.comment');
		for(i = 0; i < commentNodes.length; i++){
			this.attachThreaderEvent(commentNodes[i]);
			this.attachResponderEvent(commentNodes[i]);
		}
		
		if($('comment_references')){
			$('comment_references').onfocus = function(){ this.blur(); }
			$('comment_references').ondblclick = function(){ this.value = '' }
		}
	},
	
	attachThreaderEvent: function(node){
		var commentId = node.id.split('-').last();
		var threader = document.createElement('a');
		threader.href = 'javascript:void(0)';
		threader.className = 'commentAction';
		threader.innerHTML = 'TH' + commentId;
		threader.onclick = function(){ commentEngine.toggleThread(commentId); return false; };
		var listEl = document.createElement('li');
		listEl.appendChild(threader);
		node.select('ul.commentActions')[0].appendChild(listEl);
	},
	attachResponderEvent: function(node){
		if($('comment_references')){
			var commentId = node.id.split('-').last();
			var responder = document.createElement('a');
			responder.href = 'javascript:void(0)';
			responder.className = 'commentAction';
			responder.innerHTML = 'RE' + commentId;
			responder.onclick = function(){
				var origVal = $('comment_references').value;
				if(!origVal.match(new RegExp('@' + commentId + '\\W')) &&
					 !origVal.match(new RegExp('@' + commentId + '$'))){
					var returnVal = $('comment_references').value.strip() + ' @' + commentId;
					$('comment_references').value = returnVal.strip();
				};
				return false;
			};
			var listEl = document.createElement('li');
			listEl.appendChild(responder);
			node.select('ul.commentActions')[0].appendChild(listEl);
		}
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
			this.addComment(commentId, referenceIds);
		};
	},
	
	addComment: function(commentId, referenceIds){
		var comment = new Comment(commentId, referenceIds);
		this.indexReference(comment);
		this.comments.push(comment);
	},
	removeComment: function(commentId){
		var comment = this.comments.find(function(com){ return com.id == commentId });
		this.unindexReference(comment.id);
		this.comments = this.comments.without(comment);
	},
	
	indexReference: function(comment){
		if(this.commentAssociations.get(comment.id)){
			this.commentAssociations.set(comment.id, this.commentAssociations.get(comment.id).concat(comment.referenceIds).uniq());
		} else {
			this.commentAssociations.set(comment.id, comment.referenceIds);
		};
		for(var i = 0; i < comment.referenceIds.length; i++){
			this.inverseIndex(comment.referenceIds[i], comment.id);
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
	unindexReference: function(comment){
		if(this.commentAssociations.get(comment.id)){
			this.commentAssociations.set(comment.id, this.commentAssociations.get(comment.id).without(comment.id));
		};
		for(var i = 0; i < comment.referenceIds.length; i++){
			this.inverseUnindex(comment.referenceIds[i], comment.id);
		}
	},
	inverseUnindex: function(referenceId, commentId){
		var referenceIds;
		if(referenceIds = this.commentAssociations.get(referenceId)){
			if(referenceIds.include(commentId)){
				this.commentAssociations.set(referenceId, referenceIds.without(commentId));
			};
		}
	},
	
	toggleThread: function(commentId){
		if(this.showingThread){
			if(this.showingThread != commentId){
				var engine = this;
				this.unshowThread(this.showingThread, function(){engine.showThread(commentId)});
			} else {
				this.unshowThread(commentId);
			}
		} else {
			this.showThread(commentId);	
		}		
	},
	showThread: function(commentId){
		var thread = this.commentAssociations.get(commentId);
		var otherIds = this.comments.collect(function(com){ return com.id }).reject(function(id){ return commentId == id || thread.include(id) });
		this.hiddenCommentIds = otherIds;
		this.showingThread = commentId;
		$('comment-' + commentId).addClassName('comment-showing');
		//otherIds.collect(function(id){ return $('comment-' + id) }).invoke('blindUp', {duration: 0.3});
		var els = otherIds.collect(function(id){ return $('comment-' + id) });
		els.each(function(el){
			el.blindUp({duration: 0.3, afterFinish: (els.last() == el) ? function(){
				Scroller.to('comment-' + commentId);
				setTimeout("$('comment-" + commentId + "').highlight()", 600);
				} : null})
		});
		//Scroller.to('comment-' + commentId);
	},
	unshowThread: function(commentId, onComplete){
		var els = this.hiddenCommentIds.collect(function(id){ return $('comment-' + id) });
		this.showingThread = null;
		this.hiddenCommentIds = [];
		$('comment-' + commentId).removeClassName('comment-showing');
		if(els.length == 0){
			onComplete();
		} else {
			els.each(function(el){
				el.blindDown({duration: 0.3, afterFinish: (onComplete && els.last() == el) ? onComplete : null});
			});
		}
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