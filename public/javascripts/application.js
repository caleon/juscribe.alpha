// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var NickUpdatesForm = Behavior.create({
	onblur: function(e) {
		inputted = this.element.value;		
		el = $('blog_short_name-info');
		if(inputted && inputted != '' && !el.innerHTML.match(inputted)) {
			el.innerHTML = el.innerHTML.gsub('your_nick', inputted);
		}
	}
});

var ToggleInfoField = Behavior.create({
	onfocus: function(e) {
		targetId = this.element.id + '-info';
		errorId = this.element.id + '-error';
		if($(targetId) && (!$(errorId) || $(errorId).innerHTML == '')) {
			$(targetId).show();
		}
		return false;		
	},
	onblur: function(e) {
		targetId = this.element.id + '-info';
		errorId = this.element.id + '-error';
		if($(targetId) && (!$(errorId) || $(errorId).innerHTML == '')) {
			$(targetId).hide();
		}
		return false;
	}
});

var ShowTaggingModalBox = Behavior.create({
	onclick: function(e) {
		Modalbox.show(this.element.href + '.js', {title: this.element.title, width: 600});
		return false;
	}
});

// Didn't work.
var MakeRemoteForm = Behavior.create({
	onsubmit: function(e) {
		//new Ajax.Request(this.element.action, {asynchronous:true, evalScripts:true, parameters:Form.serialize(this)});
		//return false;
		alert('that works');
		return false;
	}
});

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
	yOffset: 100,
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
	effectsInProgress: false,
	comments: [],
	activeCommentIds: [],
	hiddenCommentIds: [],
	commentAssociations: new Hash(),
	commentsIndex: new Hash(),
	paragraphAssocations: new Hash(),
	
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
			// Following is a hack since blind effects needs explicit height on elements.
			commentNodes[i].style.height = commentNodes[i].getHeight() + 'px';
		}
		
		var paragraphs = $$('span.mixedComment');
		for(i = 0; i < paragraphs.length; i ++){
			this.addParagraphBehavior(paragraphs[i]);
		};
		
		if($('comment_references')){
			$('comment_references').onfocus = function(){ this.blur(); }
			$('comment_references').ondblclick = function(){ this.value = '' }
		}
	},
	
	addParagraphBehavior: function(node){
		var paragraph_id = node.className.match(/-p-([a-z0-9]{7})-/).last();
		if($('comment_references')){
			node.onclick = function(){
				var origVal = $('comment_references').value;
				if(!origVal.match(new RegExp(paragraph_id))){
					var returnVal = origVal.strip() + ' ' + paragraph_id;
					$('comment_references').value = returnVal.strip();
					Scroller.to('commentForm');
				};
		//		if(this.showingThread && this.showingThread)
			}
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
					var returnVal = origVal.strip() + ' @' + commentId;
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
			var paragraphHash = commentNode.getAttribute('paragraph_hash');
			var references = commentNode.getElementsByTagName('reference_id');
			var referenceIds = new Array;
			for(var j = 0; j < references.length; j++){
				var reference = references[j];
				referenceIds.push(reference.firstChild.nodeValue);
			};
			this.addComment(commentId, referenceIds, paragraphHash);
		};
	},
	
	addComment: function(commentId, referenceIds, paragraphHash){
		var comment = new Comment(commentId, referenceIds, paragraphHash);
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
				this.unshowThread(this.showingThread);
				this.showThread(commentId);
			} else {
				this.unshowThread(commentId);
			}
		} else {
			this.showThread(commentId);	
		}		
	},
	checkEffects: function(){
		return this.effectsInProgress
	},
	showThread: function(commentId){
		var thread = this.commentAssociations.get(commentId);
		var otherIds = this.comments.collect(function(com){ return com.id }).reject(function(id){ return commentId == id || thread.include(id) });
		this.hiddenCommentIds = otherIds;
		this.showingThread = commentId;
		var comment = $('comment-' + commentId);
		comment.addClassName('comment-showing');
		
		var els = otherIds.collect(function(id){ return $('comment-' + id) });
		var lastEl = els.pop();
		els.invoke('blindUp', {duration: 0.05, queue: 'end'});
		if(lastEl){
			lastEl.blindUp({duration: 0.05, queue: 'end', afterFinish: function(){
					Scroller.to('comment-' + commentId);
					//setTimeout("$('comment-" + commentId + "').highlight({queue: {position: 'end', scope: 'highlight'}})", 600);
				}
			});
		};
	},
	unshowThread: function(commentId){
		//Effect.Queues.get('highlight').invoke('cancel');
		var els = this.hiddenCommentIds.collect(function(id){ return $('comment-' + id) });
		this.showingThread = null;
		this.hiddenCommentIds = [];
		if(els.length > 0){
			els.invoke('blindDown', {duration: 0.05, queue: 'front'});
		}
		$('comment-' + commentId).removeClassName('comment-showing');
	}
};

var Comment = Class.create();
Comment.prototype = {
	id: null,
	referenceIds: null,
	paragraphHash: null,
	
	initialize: function(id, referenceIds, paragraphHash){
		this.id = id;
		if(referenceIds){
			this.referenceIds = referenceIds;
		};
		this.paragraphHash = paragraphHash;
	}
};