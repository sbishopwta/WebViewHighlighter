
var claritas = {
    hiliter: null,
   
    init: function(isTablet) {
        if(typeof rangy != 'undefined')
        {
            this.hiliter = rangy.createHighlighter();
            this.hiliter.addClassApplier(rangy.createCssClassApplier("claritasHilite", {normalize: true}));
        }
        
        var noteRightPos = isTablet ? 30 : 10;
        var style = document.createElement('style');
        style.type = 'text/css';
        style.innerHTML = '.claritasHilite { background-color: #B9E3D5; } \n' +
            '.claritasNote { position: absolute; right: ' + noteRightPos + 'px; width: 18px; height: 20px; } \n' +
            'body { -webkit-text-size-adjust: none; }';
        document.getElementsByTagName('head')[0].appendChild(style);
        
        if(isTablet)
        {
            document.body.style.cssText = "padding-left: 80px; padding-right: 80px;";
        }
        else
        {
            document.body.style.cssText = "padding-right: 10px;";
        }
        
        this.hideMathMLFallbacks();

        Element.prototype.documentOffsetTop = function () {
            return this.offsetTop + ( this.offsetParent ? this.offsetParent.documentOffsetTop() : 0 );
        };
        
        // Force a redraw of the webview in iOS 6.
        var sections=document.getElementsByTagName("section");
        for( var i = 0; i < sections.length; i++)
        {
            var note = this.createNoteElement(-1);
            sections[i].appendChild(note);
            var forceReflow = sections[i].scrollTop;
            sections[i].removeChild(note);
        }
        
    },
    
    hideMathMLFallbacks: function() {
        var epubSwitches = document.body.getElementsByTagName("switch");
        var cloned = Array.prototype.slice.call(epubSwitches, 0);
        
        if(epubSwitches)
        {
            for( var i = 0; i < cloned.length; i++)
            {
                var epubParent = cloned[i].parentNode;
                var img = cloned[i].getElementsByTagName("img");
                var span = document.createElement('span');
                span.innerHTML = "&#x00a0;";
                span.appendChild(img[0]);
                epubParent.replaceChild(span, cloned[i]);
            }
        }
    },
    
    createNoteElement: function(noteNumber) {
        var note = document.createElement('a');
        note.setAttribute('href', 'claritasinternal://note/' + noteNumber);
        note.className = 'claritasNote';
        note.innerHTML = '<img id="note-' + noteNumber + '" src="claritasinternal://asset.local/icn_note" ' +
            'style="max-width: 100%; max-height: 100%;" />';

        return note;
    },
    
    serializeSelection: function() {
        var selection = rangy.getSelection();
        
        var saved = selection.saveCharacterRanges(document.body);
        return JSON.stringify(saved);
    },
    
    createNoteForSelection: function(noteNumber) {
        var selection = rangy.getSelection();
        var range = selection.getRangeAt(0);
        
        var saved = selection.saveCharacterRanges(document.body);
        
        var note = this.createNoteElement(noteNumber);
        range.insertNode(note);
        
        var serialized = JSON.stringify(saved);
        return serialized;
    },
    
    createNoteAtSerializedRange: function(serializedRange, noteNumber) {
        var saved = JSON.parse(serializedRange);
        rangy.getSelection().restoreCharacterRanges(document.body, saved);
        
        var note = this.createNoteElement(noteNumber);
        var range = rangy.getSelection().getRangeAt(0);
        range.insertNode(note);
    },
    
    scrollToNote: function(noteNumber) {
        var top = document.getElementById( 'note-' + noteNumber ).documentOffsetTop() - ( window.innerHeight / 4 );
        window.scrollTo( 0, top );
    },
    
    scrollToId: function(id) {
        var top = document.getElementById( id ).documentOffsetTop();
        window.scrollTo( 0, top );
    },
    
    getScrollPercent: function() {
        var scroll = document.body.scrollTop / (document.body.scrollHeight - document.documentElement.clientHeight);
        return scroll.toFixed(2);
    },
    
    getScrollTopText: function() {
        var ps=document.getElementsByTagName("p");
        var scroll = document.body.scrollTop;
        var closest = null, distance = 99999;
        for( var i = 0; i < ps.length; i++)
        {
            var element = ps[i];
            var dist = Math.abs(scroll - element.offsetTop);
            if(dist < distance)
            {
                closest = element;
                distance = dist;
            }
        }
        
        var string = "";
        if(closest)
        {
            string = closest.textContent.substring(0, 150);
            string = string.replace(/(\r\n|\n|\r|\s+)/gm," ")
        }
        return string;
    },
    
    scrollToPercent: function(percent) {
        var scrollHeight = document.body.scrollHeight - document.documentElement.clientHeight;
        window.scrollTo(0, scrollHeight * percent);
    }
}