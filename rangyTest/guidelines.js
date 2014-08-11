String.prototype.replaceAll = function (find, replace) {
    var str = this;
    return str.replace(new RegExp(find.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&'), 'g'), replace);
};

/**
 * Highlighter
 */
var highlighterClassName = "HighLighto";
var highlighter = null;

var h2ClassName = "HighLighto2";
var h2 = null;

function toastSelection(){
	var selection = rangy.getSelection();
	var saved = selection.saveCharacterRanges(document.body);
	window.guidelines.toastSelection(JSON.stringify(saved));
}

function log(l){
    window.guidelines.Log(l);
}

/**
 * Initialize
 */
function init(){
    window.guidelines.Log("inito");
    highlighter = rangy.createHighlighter();
    highlighter.addClassApplier(rangy.createCssClassApplier(this.highlighterClassName,
        {normalize: true}));

    h2 = rangy.createHighlighter();
    h2.addClassApplier(rangy.createCssClassApplier(this.h2ClassName, {normalize: true}));

    log($('html').html());
}

/**
 * Create Note Functions
 */
function createNoteFromSelection(noteNumber){

    var oldSerializedHighlights = highlighter.serialize();

    var selection = rangy.getSelection();
    highlighter.highlightSelection(highlighterClassName, selection);

    var newSerializedHighlights = highlighter.serialize();
    var noteId = getId(oldSerializedHighlights, newSerializedHighlights);

    window.guidelines.saveHighlightedText(noteId, highlighter.serialize(), selection.toString());
    rangy.getSelection().removeAllRanges();

}

function highliteInitialSelections(serializedHighlights){
    highlighter.removeAllHighlights();
    highlighter.deserialize(serializedHighlights);
}

function removeNote(position, start, end){

    log($('html').html());

    var idName = "id=\"note_" + (position - 1) + "\"";

    // Shift the start/end char ranges to account for the id attribute added to the highlighted sections
    start = start - idName.length;
    end = end - idName.length;

    log("removeNote start: " + start + " end: " + end);

    var serializedSelection = "[{\"characterRange\":{\"start\":" + start + ",\"end\":" + end + "},\"backward\":false}]"
    log("range: " + serializedSelection);

    var selection = JSON.parse(serializedSelection);
    var rangySelection = rangy.getSelection().restoreCharacterRanges(document.body, selection);

    //h2.highlightSelection(highlighterClassName, rangySelection);

    highlighter.unhighlightSelection(rangySelection);
    window.guidelines.noteHighlightRemoved(this.highlighter.serialize());

    log($('html').html());

    $('#note_' + position).contents().unwrap();

    log($('html').html());

    //$('#note_' . noteNumber).content().unwrap();
    //window.guidelines.removedNote(highlighter.serialize());
}

function removeAllNotes(){
	$('.HighLighto').content().unwrap();
}

function scrollToId(idName){
    $(window).scrollTop($('#' + idName).offset().top);
}

function addNoteClickListener(noteNumber, noteInnerHtml){

    $('.HighLighto').each(function(index){

        if(noteInnerHtml.indexOf($(this).text()) > -1){

            $(this).attr('id', 'note_' + noteNumber);
            $(this).unbind('click');
            $(this).click(function(){
                window.guidelines.noteClicked($(this).attr('id'));
            });

        }
    });

}

function addClickListenersToHighlights(){
    $('.HighLighto').unbind('click');
    $('.HighLighto').click(function(){

        var innerHighlightoHtml = $(this).html();

        $('.HighLighto').each(function(index){
            if(innerHighlightoHtml == $(this).html()){
                window.guidelines.noteClicked(index);
                return false;
            }
        });
    });
    $('.HighLighto').each(function(index){
        $(this).attr('id','note_' + index);
    });
}

/**
 * Document Height
 */
function getDocHeight() {
    return document.height == null ? $(document).height() : document.height;
}

/**
 * Copy
 */
function copy(){
	var selection = rangy.getSelection();
    window.guidelines.copyToClipboard(selection.toString());
}

/**
 * Get selected html content
 */
function getHTMLOfSelection () {
    var range;
    if (document.selection && document.selection.createRange) {

        range = document.selection.createRange();
        return range.htmlText;

    }else if (window.getSelection) {

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
    }else {
       return '';
    }
}

/**
 * Get HTML content
 */
function getHtmlContent(){
    var html = document.getElementsByTagName('html')[0].innerHTML;
    window.guidelines.htmlContent(html);
}

/**
 * Ranges
 */
function Range(s, e, i, c){
    this.start = s;
    this.end =  e;
    this.id = i;
    this.className = c;
}

function getRanges(old){
    var ranges = [];
    var sections = old.split("|");
    if(sections.length > 1){
        for(var i = 1; i < sections.length; i++){
            var parts = sections[i].split("$");
            if(parts.length > 0){
                ranges.push(new Range(parts[0], parts[1], parts[2], parts[3]));
            }
        }
    }
    return ranges;
}

function containsRange(array, range){
    for(var i = 0; i < array.length; i++){
        var arrayRange = array[i];
        if(arrayRange.start == range.start && arrayRange.end == range.end){
             return true;
        }
    }
    return false;
}

function getId(oldSerialized, newSerialized){
    var id = -1;
    var oldRanges = getRanges(oldSerialized);
    var newRanges = getRanges(newSerialized);

    for(var i = 0; i < newRanges.length; i++){
        if(!containsRange(oldRanges, newRanges[i])){
            return newRanges[i].id;
        }
    }
    return id;
}