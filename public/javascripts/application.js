// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var Browser = Class.create();
Browser.prototype = {
	dom_el: '',
	preview_pane: null,
	lastClicked: {},
	
	initialize: function(dom_el, preview_pane){
		this.dom_el = dom_el;
		this.preview_pane = preview_pane;
	},
	setActiveLink: function(el, lvl){
		Element.addClassName(el, 'active')
		if (this.lastClicked[lvl] && this.lastClicked[lvl] != el) {
			Element.removeClassName(this.lastClicked[lvl], 'active');
		}
		this.lastClicked[lvl] = el;
		$(this.preview_pane + '-inner').innerHTML = 'Nothing selected';
	}
};

var MsmLayout = Class.create();
MsmLayout.prototype = {
	heightOffsets: ['padding-top', 'padding-bottom', 'border-top-width', 'border-bottom-width'],
	initialize: function(){},
	equalizeWidgetHeights: function(el1_id, el2_id){
		els = [ $(el1_id), $(el2_id) ];
		targetHeight = els.max(function(el){ return el.getHeight(); });
		shortEl = els.find(function(el){ return el.getHeight() != targetHeight; });
		diff = targetHeight - shortEl.getHeight();
		
		adjuster = shortEl.childElements().find(function(e){ return e.className.match(/inner|content/); });
		otherHeights = this.getOtherHeights(adjuster);
		trueHeight = adjuster.getHeight() - otherHeights;		
		adjuster.style.height = trueHeight + diff + 'px';
	},
	
	equalizeColumnHeights: function(col1_id, col2_id){
		els = [ $(col1_id), $(col2_id) ];
		targetHeight = els.max(function(el){ return el.getHeight(); });
		shortEl = els.find(function(el){ return el.getHeight() != targetHeight; });
		diff = targetHeight - shortEl.getHeight();
		
		adjuster = shortEl.childElements().last().childElements().find(function(el){ return el.className.match(/inner|content/); });
		otherHeights = this.getOtherHeights(adjuster);
		trueHeight = adjuster.getHeight() - otherHeights;
		adjuster.style.height = trueHeight + diff + 'px';
	},
	
	getOtherHeights: function(el){
		return this.heightOffsets.inject(0, function(acc, s){
			return acc + parseInt(el.getStyle(s));
		});
	}
};