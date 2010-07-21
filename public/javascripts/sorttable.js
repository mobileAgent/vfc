addEvent(window, "load", sortables_init);

var SORT_COLUMN_INDEX;

function sortables_init() {
    // Find all tables with class sortable and make them sortable
    if (!document.getElementsByTagName) return;
    tbls = document.getElementsByTagName("table");
    for (ti=0;ti<tbls.length;ti++) {
        thisTbl = tbls[ti];
        if (((' '+thisTbl.className+' ').indexOf("sortable") != -1) && (thisTbl.id)) {
            ts_makeSortable(thisTbl);
        }
    }
}

function ts_makeSortable(table) {
    
    if (table.tHead == null && table.tFoot == null && table.rows && table.rows.length > 0) {
      var firstRow = table.rows[0];
    } else if (table.tHead != null && table.tHead.rows.length > 0) {
      var firstRow =table.tHead.rows[0];
    }
    if (!firstRow) return;
    
    // We have a first row: assume it's the header, and make its contents clickable links
    for (var i=0;i<firstRow.cells.length;i++) {
        var cell = firstRow.cells[i];
	if (cell.className.indexOf("nosort") != -1) continue;
	var ttl = (cell.title + ' Click to sort this column');
	var txt = ts_getInnerText(cell);
	cell.innerHTML = '<a href="#" class="sortheader" onclick="ts_resortTable(this,'+i+');return false;" title="'+ttl+'">'+txt+'<span class="sortarrow"></span></a>';
    }
}

function ts_getInnerText(el) {
	if (typeof el == "string") return el;
	if (typeof el == "undefined") { return el };
	if (el.innerText) return el.innerText;	//Not needed but it is faster
	var str = "";
	
	var cs = el.childNodes;
	var l = cs.length;
	for (var i = 0; i < l; i++) {
		switch (cs[i].nodeType) {
			case 1: //ELEMENT_NODE
				str += ts_getInnerText(cs[i]);
				break;
			case 3:	//TEXT_NODE
				str += cs[i].nodeValue;
				break;
		}
	}
	return str;
}

function ts_resortTable(lnk,clid) {
    // get the span
    var span;
    for (var ci=0;ci<lnk.childNodes.length;ci++) {
        if (lnk.childNodes[ci].tagName && lnk.childNodes[ci].tagName.toLowerCase() == 'span') span = lnk.childNodes[ci];
    }
    var td = lnk.parentNode;
    var column = clid || td.cellIndex; // safari hack
    var table = getParent(td,'TABLE');
    var rlen = table.tBodies[0].rows.length;

    // Quick sort on one row :)
    if (rlen <= 1) return;
    
    // Find a suitable row to fool around with
    var idx = 0;
    while (idx < rlen &&
	   (table.tBodies[0].rows[idx].className.indexOf('sep') > -1 ||
	    ts_getInnerText(table.tBodies[0].rows[idx].cells[column]) == '')) {
      idx++;
    }
    
    // Work out a type for the column
    var itm = ts_getInnerText(table.tBodies[0].rows[idx].cells[column]);
    sortfn = ts_sort_caseinsensitive;
    if (itm.match(/^\d\d[\/-]\d\d[\/-]\d\d\d\d$/)) sortfn = ts_sort_date;
    else if (itm.match(/^\d\d[\/-]\d\d[\/-]\d\d$/)) sortfn = ts_sort_date;
    else if (itm.match(/^--\d\d\d\d--$/)) sortfn = ts_sort_date;
    else if (itm.match(/^[-\d]{2}[\/-][-\d]{2}[\/-]\d\d$/)) sortfn = ts_sort_date;
    else if (itm.match(/^[£$]/)) sortfn = ts_sort_currency;
    else if (itm.match(/^\d+:\d+:\d+$/)) sortfn = ts_sort_duration;
    else if (itm.match(/^[\d\.]+/)) sortfn = ts_sort_numeric;
    SORT_COLUMN_INDEX = column;

    var newRows = new Array();
    var k=0;
    for (j=0;j<rlen;j++) {
      if (table.tBodies[0].rows[j].className.indexOf('sep') == -1) {
	newRows[k++] = table.tBodies[0].rows[j];
      } else if (table.tBodies[0].rows[j].className.indexOf('hidden') == -1) {
	// hide our sep rows during sorting.
	table.tBodies[0].rows[j].className += ' hidden';
      }
    }

    newRows.sort(sortfn);

    if (span.getAttribute("sortdir") == 'down') {
        newRows.reverse();
        span.setAttribute('sortdir','up');
    } else {
        span.setAttribute('sortdir','down');
    }
    
    // We appendChild rows that already exist to the tbody,
    // so it moves them rather than creating new ones
    var nrlen = newRows.length;
    for (i=0;i<nrlen;i++) {
      newRows[i].className = (i%2==0 ? 'odd' : 'even');
      table.tBodies[0].appendChild(newRows[i]);
    }
    
    // Delete any other arrows there may be showing
    var allspans = table.getElementsByTagName("span");
    for (var ci=0;ci<allspans.length;ci++) {
        if (allspans[ci].className == 'sortarrow' && allspans[ci] != span) {
	  allspans[ci].setAttribute('sortdir','none');
	}
    }
}

function getParent(el, pTagName) {
  if (el == null) return null;
  else if (el.nodeType == 1 && el.tagName.toLowerCase() == pTagName.toLowerCase())	// Gecko bug, supposed to be uppercase
    return el;
  else
    return getParent(el.parentNode, pTagName);
}
function ts_sort_date(a,b) {
  // y2k notes: two digit years less than 50 are treated as 20XX, 
  // greater than 50 are treated as 19XX
  if (a && a.cells && a.cells.length >= SORT_COLUMN_INDEX)
    aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]);
  else
    aa = '00/00/0000';
  if (b && b.cells && b.cells.length >= SORT_COLUMN_INDEX)
    bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]);
  else
    bb = '00/00/0000';

  var ayr, byr, amo, bmo, aday, bday;

  if (/-{0,2}\d\d\d\d-{0,2}/.test(aa)) {
    ayr = aa.substr(2,4);
    amo = 0;
    aday = 0;
  } else if (aa.length == 10) {
    amo = aa.substr(0,2);
    aday = aa.substr(3,2);
    ayr = aa.substr(6,4);
  } else {
    amo = aa.substr(0,2);
    aday = aa.substr(3,2);
    ayr = aa.substr(6,2);
  }
  if (/-{0,2}\d\d\d\d-{0,2}/.test(bb)) {
    byr = bb.substr(2,4);
    bmo = 0;
    bday = 0;
  } else if (bb.length == 10) {
    bmo = bb.substr(0,2);
    bday = bb.substr(3,2);
    byr = bb.substr(6,4);
  } else {
    bmo = bb.substr(0,2);
    bday = bb.substr(3,2);
    byr = bb.substr(6,2);
  }

  if (aday == '--') aday = 0; else aday = parseInt(aday);
  if (ayr == '--') ayr = 0; 
  else if (ayr.length == 2 && parseInt(ayr) < 50) ayr = '20'+ayr;
  else if (ayr.length == 2) ayr = '19'+ayr;
  else ayr = parseInt(ayr);
  if (amo == '--') amo = 0; else amo = parseInt(amo);
  if (bday == '--') bday = 0; else bday = parseInt(bday);
  if (bmo == '--') bmo = 0; else bmo = parseInt(bmo);
  if (byr == '--') byr = 0;
  else if (byr.length == 2 && parseInt(byr) < 50) byr = '20'+byr;
  else if (byr.length == 2) byr = '19'+byr;
  else byr = parseInt(byr);

  if (isNaN(ayr)) ayr = 0;
  if (isNaN(amo)) amo = 0;
  if (isNaN(aday)) aday = 0;
  if (isNaN(byr)) byr = 0;
  if (isNaN(bmo)) bmo = 0;
  if (isNaN(bday)) bday = 0;

  if (ayr == byr) {
    if (amo == bmo) {
      if (aday == bday) {
	return 0;
      } else {
	return aday - bday;
      }
    } else {
      return amo - bmo;
    }
  }  else {
    return ayr - byr;
  }
}

function ts_sort_currency(a,b) { 
  if (a && a.cells && a.cells.length >= SORT_COLUMN_INDEX)
    aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]).replace(/[^0-9.]/g,'');
  else
    aa = '0';
  if (b && b.cells && b.cells.length >= SORT_COLUMN_INDEX)
    bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]).replace(/[^0-9.]/g,'');
  else 
    bb = '0';
  return parseFloat(aa) - parseFloat(bb);
}

function ts_sort_numeric(a,b) { 
  if (a && a.cells && a.cells.length >= SORT_COLUMN_INDEX)
      aa = parseFloat(ts_getInnerText(a.cells[SORT_COLUMN_INDEX]).replace(/[^\d\.].*/g,''));
  if (isNaN(aa)) aa = 0;
  
  if (b && b.cells && b.cells.length >= SORT_COLUMN_INDEX)
      bb = parseFloat(ts_getInnerText(b.cells[SORT_COLUMN_INDEX]).replace(/[^\d\.].*/g,'')); 
  if (isNaN(bb)) bb = 0;
    return aa-bb;
}
    
function ts_sort_duration(a,b) { 
    var aa,bb = 0;
    
  if (a && a.cells && a.cells.length >= SORT_COLUMN_INDEX)
      grps = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]).replace(
          /^(\d+):(\d+):(\d+)$/,
          function ($0,$1,$2,$3) {
              aa = dur_to_time($0,$1,$2,$3)
          });
  if (isNaN(aa)) aa = 0;
  
  if (b && b.cells && b.cells.length >= SORT_COLUMN_INDEX)
      grps = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]).replace(
          /^(\d+):(\d+):(\d+)$/,
          function($0,$1,$2,$3) {
              bb = dur_to_time($0,$1,$2,$3)
          });
    if (isNaN(bb)) bb = 0;
    //alert("a/b => " + ts_getInnerText(a.cells[SORT_COLUMN_INDEX]) + "/" + ts_getInnerText(b.cells[SORT_COLUMN_INDEX]) + " ==> " + aa + " / " + bb);
    return aa-bb;
}

function dur_to_time(a,b,c,d) {
    return parseInt(d)  + (parseInt(c) * 60) + (parseInt(b) * 3600);
}

function ts_sort_caseinsensitive(a,b) {
  if (a && a.cells && a.cells.length >= SORT_COLUMN_INDEX)
    aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]).toLowerCase();
  else 
    aa = '';
  if (b && b.cells && b.cells.length >= SORT_COLUMN_INDEX)
    bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]).toLowerCase();
  else
    bb = '';
  if (aa==bb) return 0;
  if (aa<bb) return -1;
  return 1;
}

function ts_sort_default(a,b) {
  if (a && a.cells && a.cells.length >= SORT_COLUMN_INDEX)
    aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]);
  else 
    aa = '';
  if (b && b.cells && b.cells.length >= SORT_COLUMN_INDEX)
    bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]);
  else
    bb = '';

  if (aa==bb) return 0;
  if (aa<bb) return -1;
  return 1;
}


function addEvent(elm, evType, fn, useCapture)
// addEvent and removeEvent
// cross-browser event handling for IE5+,  NS6 and Mozilla
// By Scott Andrew
{
  if (elm.addEventListener){
    elm.addEventListener(evType, fn, useCapture);
    return true;
  } else if (elm.attachEvent){
    var r = elm.attachEvent("on"+evType, fn);
    return r;
  } else {
    alert("Handler could not be removed");
  }
} 
