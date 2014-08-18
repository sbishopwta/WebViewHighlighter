var guidelines = {
    
highlighter: null,
    
init: function (isTablet) {
    this.highlighter = rangy.createHighlighter();
    this.highlighter.addClassApplier(rangy.createCssClassApplier("HighLighto", {
                                                                 normalize: true
                                                                 }));
},
    
createNoteFromSelection: function () {
    var oldSerializedHighlights = this.highlighter.serialize();
    var selection = rangy.getSelection();
    this.highlighter.highlightSelection("HighLighto", selection);
    var newSerializedHighlights = this.highlighter.serialize();
//        var noteId = getId(oldSerializedHighlights, newSerializedHighlights);
    var noteId = 1;
    
    var selectionString = selection.toString();
    
    rangy.getSelection().removeAllRanges();
    
    var note = {
        "noteId": noteId,
        "serializedHighlights": newSerializedHighlights,
        "selection": selectionString
    };
    return JSON.stringify(note);
},
    
removeNote: function (position, start, end) {
    
    var idName = "id=\"note_" + (position - 1) + "\"";
    
    // Shift the start/end char ranges to account for the id attribute added to the highlighted sections
    start = start - idName.length;
    end = end - idName.length;
    
    
    var serializedSelection = "[{\"characterRange\":{\"start\":" + start + ",\"end\":" + end + "},\"backward\":false}]";
    
    var selection = JSON.parse(serializedSelection);
    var rangySelection = rangy.getSelection().restoreCharacterRanges(document.body, selection);
    
    //h2.highlightSelection(highlighterClassName, rangySelection);
    
    highlighter.unhighlightSelection(rangySelection);
    //        window.guidelines.noteHighlightRemoved(this.highlighter.serialize());
    
    
    $('#note_' + position).contents().unwrap();
    
    
    //$('#note_' . noteNumber).content().unwrap();
    //window.guidelines.removedNote(highlighter.serialize());
},
    
removeAllNotes: function () {
    $('.HighLighto').content().unwrap();
},
    
scrollToID: function (idName) {
    $(window).scrollTop($('#' + idName).offset().top);
},
    
addNoteClickListener: function (noteNumber, noteInnerHtml) {
    
    $('.HighLighto').each(function (index) {
                          
                          if (noteInnerHtml.indexOf($(this).text()) > -1) {
                          
                          $(this).attr('id', 'note_' + noteNumber);
                          $(this).unbind('click');
                          $(this).click(function () {
                                        window.guidelines.noteClicked($(this).attr('id'));
                                        });
                          
                          }
                          });
    
},
    
addClickListenersToHighlights: function () {
    $('.HighLighto').unbind('click');
    $('.HighLighto').click(function () {
                           
                           var innerHighlightoHtml = $(this).html();
                           
                           $('.HighLighto').each(function (index) {
                                                 if (innerHighlightoHtml == $(this).html()) {
                                                 window.guidelines.noteClicked(index);
                                                 return false;
                                                 }
                                                 });
                           });
    $('.HighLighto').each(function (index) {
                          $(this).attr('id', 'note_' + index);
                          });
},
    /**
     * Document Height
     */
getDocHeight: function () {
    return document.height == null ? $(document).height() : document.height;
},
    /**
     * Copy
     */
copy: function () {
    var selection = rangy.getSelection();
    window.guidelines.copyToClipboard(selection.toString());
},
    
    /**
     * Get selected html content
     */
getHTMLOfSelection: function () {
    var range;
    if (document.selection && document.selection.createRange) {
        
        range = document.selection.createRange();
        return range.htmlText;
        
    } else if (window.getSelection) {
        
        var selection = window.getSelection();
        if (selection.rangeCount > 0) {
            range = selection.getRangeAt(0);
            var clonedSelection = range.cloneContents();
            var div = document.createElement('div');
            div.appendChild(clonedSelection);
            return div.innerHTML;
        } else {
            return '';
        }
    } else {
        return '';
    }
},
    
    /**
     * Get HTML content
     */
getHtmlContent: function () {
    var html = document.getElementsByTagName('html')[0].innerHTML;
    window.guidelines.htmlContent(html);
},
    
    /**
     * Ranges
     */
Range: function (s, e, i, c) {
    this.start = s;
    this.end = e;
    this.id = i;
    this.className = c;
},
    
getRanges: function (old) {
    var ranges = [];
    var sections = old.split("|");
    if (sections.length > 1) {
        for (var i = 1; i < sections.length; i++) {
            var parts = sections[i].split("$");
            if (parts.length > 0) {
                ranges.push(new Range(parts[0], parts[1], parts[2], parts[3]));
            }
        }
    }
    return ranges;
},
    
containsRange: function (array, range) {
    for (var i = 0; i < array.length; i++) {
        var arrayRange = array[i];
        if (arrayRange.start == range.start && arrayRange.end == range.end) {
            return true;
        }
    }
    return false;
},
    
getId: function (oldSerialized, newSerialized) {
    var id = -1;
    var oldRanges = getRanges(oldSerialized);
    var newRanges = getRanges(newSerialized);
    
    for (var i = 0; i < newRanges.length; i++) {
        if (!containsRange(oldRanges, newRanges[i])) {
            return newRanges[i].id;
        }
    }
    return id;
}
    
};