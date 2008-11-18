//var myCompareTable;
//var search;

YAHOO.util.Event.addListener(window, "load", function() {
    YAHOO.example.XHR_JSON = new function() {
	var Dom = YAHOO.util.Dom;

        this.formatUrl = function(elCell, oRecord, oColumn, sData) {
            elCell.innerHTML = "<a href='" + oRecord.getData("url") + "' target='_blank'>" + sData + "</a>";
        };

	this.formatCheckBox = function(elCell, oRecord, oColumn, sData) {
		var innerHTML = "<input type='checkbox' name='listingId' value='" + sData + "' id='" + sData + "_checkBox'";
		if(typeof(oRecord.getData("checked")) != 'undefined'){
			if(oRecord.getData("checked") == 'checked'){
			innerHTML = innerHTML + " checked='checked'";
			}
		}
		innerHTML = innerHTML + ">";
            	elCell.innerHTML = innerHTML;
        };

        var myColumnDefs = [
	    {key:"checkBox",label:""},//,sortable:false,formatter:this.formatCheckBox
            {key:"title", label:"Name", sortable:true, formatter:this.formatUrl},
            {key:"views", sortable:true},
            {key:"clicks", sortable:true},
            {key:"compares", sortable:true}
        ];

	var uri = "func=getCompareFormData";
	if(typeof(listingIds) != 'undefined'){
	for (var i = 0; i < listingIds.length; i++) {
		uri = uri+';listingId='+listingIds[i];
	}
	}

        this.myDataSource = new YAHOO.util.DataSource("?");
        this.myDataSource.responseType = YAHOO.util.DataSource.TYPE_JSON;
        this.myDataSource.connXhrMode = "queueRequests";
        this.myDataSource.responseSchema = {
            resultsList: "ResultSet.Result",
            fields: ["title","views","clicks","compares","checkBox","checked","url"]
        };


        var myDataTable = new YAHOO.widget.DataTable("compareForm", myColumnDefs,
                this.myDataSource, {initialRequest:uri});

	this.myDataSource.doBeforeParseData = function (oRequest, oFullResponse) {
		
		myDataTable.getRecordSet().reset();
		return oFullResponse;
	}
	var myDataSource = this.myDataSource;

	//var oColumn = myDataTable.getColumn(3);
	//myDataTable.hideColumn(oColumn); 


        var myCallback = function() {
		myDataTable.getRecordSet().reset();
            this.set("sortedBy", null);
            this.onDataReturnAppendRows.apply(this,arguments);
        };

	var callback2 = {
            success : myCallback,
            failure : myCallback,
            scope : myDataTable
        };
		
	var reloadCompareForm = function() {
		var attributeSelects = YAHOO.util.Dom.getElementsByClassName('attributeSelect','select');
		var newUri = "func=getCompareFormData;search=1";
    		for (var i = attributeSelects.length; i--; ) {
			newUri = newUri + ';search_' + attributeSelects[i].id + '=' + attributeSelects[i].value;
        	}
		var elements = myDataTable.getRecordSet().getRecords();
		alert(elements.length);
		for(i=0; i<elements.length; i++){
			elRow = myDataTable.getTrEl(elements[i]);
			Dom.setStyle(elRow, "display", "none");
		}
		myDataTable.getRecordSet().deleteRecord(0,elements.length);
		myDataSource.sendRequest(newUri,callback2);
    	}
	var attributeSelects = YAHOO.util.Dom.getElementsByClassName('attributeSelect','select');
	for (var i = attributeSelects.length; i--; ) {
		attributeSelects[i].onchange = reloadCompareForm;
    	}
	

	
    };
});

