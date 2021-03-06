-----------------------------------------------------------------------------------------
--
-- champions.lua
-- The list of all league champions.
--
-----------------------------------------------------------------------------------------
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	
	--Add a placeholder to the group (this is a bug with the Storyboard API)
    local blah = display.newRetinaText( "blah", 18, 0, "Helvetica-Bold", 12 )
	group:insert( blah )
	blah.isVisible = false;

end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )

	local group = self.view
	local widget = require "widget"
    currentScene = "champions";

	local listOptions = {
        top = 44,
        height = 386,
        maskFile = "mask-386.png";
	}
 
    --create a tableView
	theList = widget.newTableView( listOptions )

	-- onEvent listener for the tableView
	local function onRowTouch( event )
    local row = event.target
    local rowGroup = event.view
 
    if event.phase == "press" then
    
        if not row.isCategory then rowGroup.alpha = 0.5;
               
        end
 
        elseif event.phase == "release" then
            
            if not row.isCategory then
                updateHistory(currentScene);
                -- reRender property tells row to refresh if still onScreen when content moves
                row.reRender = true
                
                --split the id value into multiple values.
                local t
                t = split(event.target.id);
                print ("Team Name changed to: " .. t[1]);
                whichTeam = t[1]
                whichTeamSeason = t[2]
               			
               	-- go to a particular teamSeason page
               	storyboard.gotoScene( "teamseason" );
                end
        end
        return true
	end
 
	-- onRender listener for the tableView that renders each row
	local function onRowRender( event )
        local row = event.target
        local rowGroup = event.view
        
        -- Decompact the row data
        local t
        t = split(event.target.id);
        local year = t[2]
        local compYear = year .. "-" .. computeNextSeason(year);
        local name = t[3]

   	 	local textDate = display.newRetinaText( compYear, 18, 0, "Helvetica-Bold", 18 )
    	textDate:setReferencePoint( display.CenterLeftReferencePoint )
    	textDate.y = row.height * 0.5
    	
    	local textName = display.newRetinaText(name, 18, 0, "Helvetica-Bold", 18);
    	textName:setReferencePoint( display.CenterLeftReferencePoint )
    	textName.y = row.height * 0.5
        
    	if not row.isCategory then
    		textDate.x = 10
    		textDate:setTextColor( 100 )
    		textName.x = 120 ;
     		textName:setTextColor(0);
    	end
 
        -- must insert everything into event.view: (tableView requirement)
        rowGroup:insert( textDate )
   		rowGroup:insert(textName);
	end
 
	
    local ilkid;
    local year;   
    local id;
		
	for row in db:nrows("SELECT * FROM records_leagueChampions ORDER BY year DESC") do
    teamName = row.teamName;
    ilkid = row.team;
	year = row.year;
	id = ilkid .. "," .. year.. "," .. teamName;

    -- function below is responsible for creating the row
    theList:insertRow{
        onEvent=onRowTouch,
        id=id,
        onRender=onRowRender,
        height=rowHeight,
        isCategory=isCategory,
        rowColor=rowColor,
        lineColor=lineColor
    }
	end

	-- all objects must be added to group (e.g. self.view) but are not in this case since widgets act problematically with group.insert
	--	group:insert( list )
	--	group:insert( title )

	--create the NavBar with the appropriate title
	createNavBar("League Champions");
    displayBackButton();
	
	--insert everything into the group to be changed on scene changes
    group:insert(navBar);
    group:insert(navHeader);
    group:insert(backButton)
end

-- Called when scene is about to move offscreen:

function scene:exitScene( event )
	local group = self.view
 	theList:removeSelf()
  	theList = nil
end

function scene:destroyScene( event )
	local group = self.view
end

-----------------------------------------------------------------------------------------
-- Do not touch below: Listeners required for the storyboard API.
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene