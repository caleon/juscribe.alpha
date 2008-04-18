// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var Browser = Class.create()
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
}