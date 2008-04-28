var MsmLayout = Class.create();
MsmLayout.prototype = {
	heightOffsets: ['padding-top', 'padding-bottom', 'border-top-width', 'border-bottom-width'],
	initialize: function(){},
	equalizeWidgetHeights: function(el1_id, el2_id){
		els = [ $(el1_id), $(el2_id) ];
		targetHeight = els.max(function(el){ return el.getHeight(); });
		if(shortEl = els.find(function(el){ return el.getHeight() != targetHeight; })){
			diff = targetHeight - shortEl.getHeight();
		
			if(adjuster = shortEl.childElements().find(function(e){ return e.className.match(/inner|content/); })){
				otherHeights = this.getOtherHeights(adjuster);
				trueHeight = adjuster.getHeight() - otherHeights;		
				adjuster.style.height = trueHeight + diff + 'px';
			}
		}
	},
	
	equalizeColumnHeights: function(col1_id, col2_id){
		els = [ $(col1_id), $(col2_id) ];
		targetHeight = els.max(function(el){ return el.getHeight(); });
		if(shortEl = els.find(function(el){ return el.getHeight() != targetHeight; })){
			diff = targetHeight - shortEl.getHeight();
		
			if(adjuster = shortEl.childElements().last().descendants().find(function(el){ return el.className.match(/inner|content/); })){
				otherHeights = this.getOtherHeights(adjuster);
				trueHeight = adjuster.getHeight() - otherHeights;
				adjuster.style.height = trueHeight + diff + 'px';
			}
		}
	},
	
	getOtherHeights: function(el){
		if(el){
			return this.heightOffsets.inject(0, function(acc, s){
				return acc + parseInt(el.getStyle(s));
			});
		} else {
			0
		}
	}
};