//Dal1980 v1.0 Hello-SNES
//July 2019 V1.0
//Based on Hello-Nintendo Theme

class UserConfig {
  </ label="BG Type", help="Choose the background image" options="PAL,USA" order=2 /> bgType="USA";
  </ label="Grid Item Art", help="Set the art to be used for the grid items (default box)" order=12 /> gridArt="box";
}

local myConfig = fe.get_config();
fe.layout.width = 1280;
fe.layout.height = 1024;

//grid options
local totalXGrid = 4; //the total items showing across a row (column items)
local totalYGrid = 2;  //the total items showing down a column (row count)
local xPadGrid = 29; //x pos grid item padding
local yPadGrid = 59; //y pos grid item padding
local wItemGrid = 166; //the width of the items in the grid
local hItemGrid = 101; //the height of the items in the grid
local xsGrid = 257; //starting x position of the overall grid
local ysGrid = 599; //starting y postion of the overall grid
local gridArt = myConfig["gridArt"]; //the chosen artwork for displaying as the grid items.
//grid initalisation
local resetDrawGrid = false; //controls when we redraw the grid
local modxGrid = 0; //adds x position modification for drawing grid
local modyGrid = 0; //adds y position modification for drawing grid
local restrictYGrid = 0; //marker for restricting the x movement on grid
local pageTurnXGrid = 0; //pagination for previous/next rows of the grid
local selectorDrawn = false; //sets the trigger for drawing the selector (init)
local textZ = 3; //sets our zorder. We need to keep this set to 3
local gridAssets = []; //A place where I grid assets are stored
local gridDrawComplete = false; //Marks the start/end of our initialisation of assets


//backgrounds
if(myConfig["bgType"] == "PAL") local bg1 = fe.add_image("parts/background-pal.png", 0, 0, 1280, 1024 );
else if(myConfig["bgType"] == "USA") local bg1 = fe.add_image("parts/background-usa.png", 0, 0, 1280, 1024 ); //future

//external assets
local snapBox = fe.add_artwork("snap", 143, 177, 465, 350);
local frontBox = fe.add_artwork("box", 661, 179, 475, 347);
local logoBox = fe.add_artwork("logo", 439, 18, 401, 120);

local favHolder = fe.add_image("parts/favourite-off.png", 1160, 969, 59, 24);

function getFavs(index_offset) {
    if(fe.game_info( Info.Favourite, 0 ) == "1") return "parts/favourite-on.png";
    else return  "parts/favourite-off.png";
}

fe.layout.font = "SNES Italic";
local labelReleased = fe.add_text("Released", 195, 46, 200, 30);
local labelYear = fe.add_text("[Year]", 190, 68, 200, 40);
labelYear.align = Align.Centre;
labelReleased.set_rgb(82, 91, 104);
labelYear.set_rgb(82, 91, 104);

local labelPlayers = fe.add_text( "[!simpleCat]", 508, 922, 600, 38);
labelPlayers.align = Align.Left;
labelPlayers.set_rgb(82, 91, 104);

local labelManuf = fe.add_text( "[Manufacturer]", 508, 978, 600, 38);
labelManuf.align = Align.Left;
labelManuf.set_rgb(36, 36, 36);

local labelTitle = fe.add_text( "[Title]", 508, 950, 600, 38);
labelTitle.align = Align.Left;
labelTitle.set_rgb(82, 91, 104);

local labelPlayedTimes = fe.add_text( "Times played", 870, 46, 200, 30);
local labelPlayedCount = fe.add_text( "[PlayedCount]", 870, 68, 200, 40);
labelPlayedTimes.align = Align.Centre;
labelPlayedCount.align = Align.Centre;
labelPlayedTimes.set_rgb(82, 91, 104);
labelPlayedCount.set_rgb(82, 91, 104);

local labelListSize = fe.add_text( "[ListEntry] of [ListSize]", 40, 978, 100, 30);
labelListSize.align = Align.Centre;
labelListSize.set_rgb(82, 91, 104);


//Custom game selector (Selector WxH: 194 x 158) (Item WxH: 166 x 101) (Difference WxH: 28 x 57)
local gameSelector1 = fe.add_image("parts/selector.png", xsGrid - 14, ysGrid - 26, wItemGrid + 28, hItemGrid + 57); //thegrid selector image (appears behind box z-order)
gameSelector1.zorder = 2; //must be 2 or greater (less than 2 hides this)


function simpleCat( ioffset ) {
  local m = fe.game_info(Info.Category, ioffset);
  local temp = split( m, " / " );
  if(temp.len() > 0) return temp[0];
  else return "";
}


function drawGrid(x, y, currentID){
    if(!gridDrawComplete){
        //we now need to use fe.get_art to find the full path to our art label    
        local artPath = fe.get_art( gridArt, currentID );
        gridAssets.append( fe.add_image(artPath, x, y, wItemGrid, hItemGrid) );
        gridAssets[ gridAssets.len() -1 ].zorder = textZ;
        //You can manipulate the objects further here
        //eg. gridAssets[ gridAssets.len() -1 ].rotation = -30;
    }
    else {        
        updateGrid(x, y, currentID, textZ - 3)
    }
    textZ++;
}

//we update once our image objects are available
function updateGrid(x, y, currentID, arrayID){
    local artPath = fe.get_art( gridArt, currentID );
    gridAssets[arrayID].file_name = artPath;
}

//This function loops through and draws our grid
function drawNextPage(currentIndex){
    if(resetDrawGrid){
        currentIndex = modyGrid + modxGrid;
        resetDrawGrid = false;
    }
    textZ = 3;
    local cia = 0; //this simply adds the incremental index 0,1,2,3...10,11.
    for(local x = 0; x < totalXGrid; x++){
    	for(local y = 0; y < totalYGrid; y++){        
            drawGrid( xsGrid + (x * (wItemGrid + xPadGrid)), ysGrid + (y * (hItemGrid + yPadGrid)), currentIndex + cia );
            cia++;
        }        
    }
    gridDrawComplete = true;
}

fe.add_transition_callback( "update_my_list" );
function update_my_list( ttype, var, ttime ) {
    favHolder.file_name = getFavs(0);
    if(ttype == Transition.StartLayout){
        drawNextPage(0);
        favHolder.file_name = getFavs(0);
    }
    else if(ttype == Transition.EndNavigation){
        if(resetDrawGrid) drawNextPage(0);
        favHolder.file_name = getFavs(0);
    } 
    return false;
}

fe.add_signal_handler( this, "on_signal" );
function on_signal( sig ) {
    if(sig == "up"){
        if(restrictYGrid > 0){
	        restrictYGrid--;
    	    fe.list.index -= 1;
        	gameSelector1.y -= (hItemGrid + yPadGrid);
        	modyGrid += 1;
        }
        return true;
    }
    else if(sig == "down"){
        if(restrictYGrid < (totalYGrid-1)){
	        restrictYGrid++;
    	    fe.list.index += 1;
        	gameSelector1.y += (hItemGrid + yPadGrid);
        	modyGrid -= 1;
        }
        return true;
    }      
    else if(sig == "left"){
		if(pageTurnXGrid <= 0){
            resetDrawGrid = true;
            pageTurnXGrid = 1;
            gameSelector1.x += (wItemGrid + xPadGrid);
            modxGrid = 0;
        } 
    	pageTurnXGrid--;
        fe.list.index -= totalYGrid;
        gameSelector1.x -= (wItemGrid + xPadGrid);        
        return true;
    }
    else if(sig == "right"){
    	if(pageTurnXGrid >= (totalXGrid - 1)){
            resetDrawGrid = true;
            pageTurnXGrid = (totalXGrid - 2);
            gameSelector1.x -= (wItemGrid + xPadGrid);
            modxGrid = -(totalYGrid*(totalXGrid - 1));
        }
    	pageTurnXGrid++;
        fe.list.index += totalYGrid;
        gameSelector1.x += (wItemGrid + xPadGrid);        
        return true;
    }
    else if(sig == "next_letter" || sig == "prev_letter" || 
            sig == "prev_favourite" || sig == "next_favourite" || 
            sig == "prev_page" || sig == "next_page"){
        gameSelector1.x = xsGrid - 6;
        gameSelector1.y = ysGrid - 6;
        resetDrawGrid = true;
        restrictYGrid = 0;
        pageTurnXGrid = 0;
        modxGrid = 0;
        modyGrid = 0;
    }
    else return false;
}

fe.layout.font = ""; //resets font