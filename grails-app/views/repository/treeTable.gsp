<html>
<head >
	<meta name="layout" content="admin"/>
	<g:javascript src="treeTable/javascripts/jquery.treeTable.js"/>
	<g:javascript src="treeTable/javascripts/core.treeTable.js"/>
	<link href="${createLinkTo(dir:pluginContextPath + '/js/treeTable/stylesheets', file:'jquery.treeTable.css')}" rel="stylesheet" type="text/css" />

<style type="text/css">
	td span.ui-icon { display: inline;}
	th {text-align: left}
	span.ui-icon-circle-triangle-e { float: left; margin-left: -2.6em; }
	.nodeinfo { font-size: 85%;}
	.nodeinfoDialog { display:none;}
	span.ui-icon-info { float: left; margin-right: 0.8em; }
	span.ui-icon-circle-plus { float: left; margin-right: 0.5em; }
	span.ui-icon-circle-minus { float: left; }
	a:hover { text-decoration: underline;}
	ul.childList { font-size: 1em}
	.ui-state-highlight { height: 1.5em; line-height: 1.2em; }

    h2.title + span.type { margin-left: 10px;}
</style>
<script type="text/javascript">

var resources = {};
var cacheParams = {};

function init(){
    var haveChildren = {};
    <g:each var="data" in="${haveChildren}">
      haveChildren["${data.key}"] = ${data.value};
    </g:each>
    resources["haveChildren"] = haveChildren;
    resources["content.button.create"] = "${message(code:'content.button.create', encodeAs:'JavaScript')}";
    resources["content.button.cancel"] = "${message(code:'content.button.cancel', encodeAs:'JavaScript')}";
    resources["link.movenode"] = "${createLink(action: 'moveNode', controller: 'repository')}";
    resources["link.copynode"] = "${createLink(action: 'copyNode', controller: 'repository')}";
    resources["link.deletenode"] = "${createLink(action: 'deleteNode', controller: 'repository')}";
    resources["link.treetable"] = "${createLink(action: 'treeTable', controller: 'repository')}";
    resources["link.preview"] = "${createLink(action: 'preview', controller: 'repository')}";
    <g:each var="status" in="${org.weceem.content.Status.list()}">
      resources["${status.description}"] = "${message(code: 'content.status.' + status.description, encodeAs:'JavaScript')}"
    </g:each>
    
    cacheParams["isAsc"] = true;
    cacheParams["sortField"] = "title";
}

function sortByField(fieldname){
    cacheParams["isAsc"] = !cacheParams["isAsc"];
    cacheParams["sortField"] = fieldname;
    sendSearchRequest(cacheParams);
    $("#searchDiv>div>table>thead>tr>th").attr("class", (cacheParams["isAsc"] ? "asc" : "desc"));
}
function catchKey(e){
    var keyID = (window.event) ? event.keyCode : e.keyCode;
    
    switch(keyID){
        //Enter pressed
        case 13:
            $("#search_btn").click();
            break;
        //Escape pressed
        case 27:
            $("#clear_btn").click();
            break;
    }
}

function sendSearchRequest(searchParams){
    $("#treeDiv").css("display", "none");
    $("#searchDiv").css("display", "");
    $("#searchDiv > div > table > tbody").html("");
    $.post("${createLink(action: 'searchRequest', controller: 'repository')}",
        searchParams,
        function(data){
            var response = eval('(' + data + ')');
            var tr = $("<tr>");
            var td = $("<td>");
            for (i in response.result){
                var obj = response.result[i];
                var body = $("#searchDiv > div > table > tbody")
                var newTr = tr.clone();
                var pageTd = td.clone();
                var statusTd = td.clone();
                var createTd = td.clone();
                var changeTd = td.clone();
                pageTd.html("<div class='item'><div class='ui-icon ui-icon-document' style='display: inline-block'></div>" + 
                "<h2 class='title'>" + "<a href=" + obj.href + ">" + obj.title + 
                "<span class='type'>(/" + obj.aliasURI + " - " + obj.type + ")</span></a></h2>" + 
                "<div >Parent: <a href='#'>"
                    + obj.parent + "/" + obj.aliasURI + "</a></div></div>");
                statusTd.text(resources[obj.status]);
                createTd.text(obj.createdBy);
                changeTd.text(obj.changedOn);
                newTr.append(pageTd); newTr.append(statusTd);
                newTr.append(createTd); newTr.append(changeTd);
                body.append(newTr);
            }
            $('#advSearch').show('slow');
        });
}


$(function(){
    document.onkeyup = catchKey;
    init();
    initTreeTable();
    $("#fromDate").datepicker();
    $("#toDate").datepicker();
    $("#search_btn").click(function(){
        cacheParams["data"] = $("#data")[0].value;
        cacheParams["space"] = $('#spaceSelector')[0].options[$('#spaceSelector')[0].selectedIndex].text;
        cacheParams["classFilter"] = ($("#advSearch").css("display") == "none" ? "none" : $("#classFilter")[0].value);
        cacheParams["fieldFilter"] = $("#fieldFilter")[0].value;
        cacheParams["fromDateFilter"] = $("#fromDate")[0].value;
        cacheParams["toDateFilter"] = $("#toDate")[0].value;
        cacheParams["statusFilter"] = $("#statusFilter")[0].value;
        sendSearchRequest(cacheParams);
    });
    $("#clear_btn").click(function(){
        cacheParams["sortField"] = "title";
        cacheParams["isAsc"] = true;
        $("#treeDiv").css("display", "");
        $("#searchDiv").css("display", "none");
        $("#data")[0].value = "";
        $("#fromDate")[0].value = "";
        $("#toDate")[0].value = "";
        $('#advSearch').hide('slow');
        $("#searchDiv > div > table > tbody").html("");
    });
})
</script>
</head>
<body>

    <div class="span-24 last">
        <div class="container">
            <table class="form">
              <tr>
               <td><g:render plugin="weceem" template="repository-buttons"/></td>
               <td>
                 <label>Space:</label>
                 <g:select id="spaceSelector" name="space" from="${spaces}" 
				 optionKey="id" optionValue="name" onchange="changeSpace()" value="${space.id}"/>
    		   </td>
    		   <td>
    		     <span id="search_btn" class="sbox_l"></span><span class="sbox"><input type="text" name="data" id="data" /></span><span id="clear_btn" class="sbox_r"></span>
    		   </td>
    		  </tr>
    		</table>
            <form controller="repository">
            	<div id="advSearch" style="display:none" class="span-24 last">
            			You can filter results by type: <g:select id="classFilter" from="${[[fullName: 'none', name: 'All']] + grailsApplication.domainClasses.findAll({org.weceem.content.Content.isAssignableFrom(it.clazz)}).sort({a,b->a.name.compareTo(b.name)})}" optionKey="fullName" optionValue="name"/>,
            			status: <g:select id="statusFilter" from="${[['description': 'all', 'code': 0]] + org.weceem.content.Status.list()}" optionKey="code" optionValue="description" />
            			and date <g:select id="fieldFilter" from="[[id:'createdOn', value:'created'], [id:'changedOn', value:'changed']]"  optionKey="id" optionValue="value"/> from <input id="fromDate" type="text"/> to <input id="toDate" type="text"/>
            	</div>
            </form>
            </div>

            <div id="treeDiv">
              <div class="table">
                <table id="treeTable">
                  <thead>
                    <tr>
                      <th align="left">Page</th>
                      <th align="left">Status</th>
                      <th align="left">Created By</th>
                      <th align="left">Last changed</th>
                      <th>&nbsp;</th>
                    </tr>
                  </thead>
                  <tbody>
                	<g:each in="${content.sort()}" var="c">
                		<g:render plugin="weceem" template="newtreeTableNode" model="[c:c]"/>
                	</g:each>
                  </tbody>
                </table>
             </div>
            </div>
            
            <div id="searchDiv" style="display: none">
                <div class="table">
                    <table class="treeTable">
                        <thead style="border-spacing: 10px 10px">
                          <tr>
                            <th align="left" class="asc"><a href="#" onclick="sortByField('title')">Page&nbsp;&nbsp;</a></th>
                            <th align="left" class="asc"><a href="#" onclick="sortByField('status.description')">Status&nbsp;&nbsp;</a></th>
                            <th align="left" class="asc"><a href="#" onclick="sortByField('createdBy')">Created By&nbsp;&nbsp;</a></th>
                            <th align="left" class="asc"><a href="#" onclick="sortByField('changedOn')">Last changed&nbsp;&nbsp;</a></th>
                          </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="span-24 last prepend-top"><g:render plugin="weceem" template="repository-buttons"/></div>

<div id="createNewDialog" class="ui-helper-hidden" title="${message(code:'content.title.create')}">
    <g:form controller="editor" action="create" method="GET">
        <input id="parentid" name="parent.id" type="hidden"></input>
        <label for="createNewType"><g:message code="content.label.type" encodeAs="HTML"/></label><br/>
        <g:select id="createNewType" name="type" from="${contentTypes.sort { message(code:'content.type.name.'+it) } }" optionValue="${ { message(code:'content.type.name.'+it) } }"/>
        <input id="spaceField" type="hidden" name="space.id" value="${params.space.id}">
    </g:form>
</div>

<div id="deleteDialog" title="Do you want to delete this node?" class="ui-helper-hidden">
	Deleting the content "<span id="deleteContentNodeTitle"></span>" will delete all its child nodes - you cannot undo this.
	Continue with delete?
</div>

<div id="moreActionsMenu" class="ui-helper-hidden">
    <ul>
        <li><a href="#" class="viewAction"><g:message code="command.view" encodeAs="HTML"/></a></li>
        <li><a href="#" class="deleteAction"><g:message code="command.delete" encodeAs="HTML"/></a></li>
        <li><a href="#" class="moveToSpaceAction"><g:message code="command.moveToSpace" encodeAs="HTML"/></a></li>
        <li><a href="#" class="duplicateAction"><g:message code="command.duplicate" encodeAs="HTML"/></a></li>
    </ul>
</div>

<div id="confirmDialog" title="Confirm your action" class="ui-helper-hidden">
	Please, choose one from the following actions:
</div>

<div id="expiredDialog" title="Session Expired" class="ui-helper-hidden">
	${ message(code:'message.session.expired') }
</div>

</body>
</html>
