-- handle collisions concerning the "submarine" name
-- no way to determine who is who, so we write both conditions
if ( obj1.myName == "submarine" or obj2.myName == "submarine" ) then

    -- rename for convenience
    local collidingObj
    if ( obj1.myName == "submarine" ) then
        collidingObj = obj2
    else
        collidingObj = obj1
    end

    -- handle collision with pickable object type ----------------------------------
    if ( collidingObj.myType == "pickableObject" ) then
        -- update score and sea life based on name of "collidingObj"
        if ( collidingObj.myName == "groundObject" ) then
            score = score + 100
            seaLife = seaLife + 200

        elseif ( collidingObj.myName == "floatingObject" ) then
            score = score + 50
            seaLife = seaLife + 100
        end

        -- check bounds of sea life
        if ( seaLife > seaLifeMax ) then
            seaLife = seaLifeMax
        end

        -- update score text
        scoreText.text = "Score: " .. score
        
        -- update sea life bar
        seaLifeProgressView:setProgress( seaLife / seaLifeMax )

        -- remove "collidingObj" reference from "screenObjectsTable"
        local screenObjectsTable = composer.getVariable( "screenObjectsTable" )
        for i = #screenObjectsTable, 1, -1 do
            if ( screenObjectsTable[i] == collidingObj ) then
                table.remove( screenObjectsTable, i )
                break
            end
        end

        -- remove "collidingObj" from display
        display.remove( collidingObj )
    
    -- handle collision with "obstacleObject" type -----------------------------
    elseif ( collidingObj.myType == "obstacleObject" ) then
        gameOver()
    end

-- handle collisions concerning the "obstacleObject" type
-- this check is done to avoid losing score on objects that are impossible to pick, deleting them from game
elseif ( obj1.myType == "obstacleObject" or obj2.myType == "obstacleObject" ) then

    -- rename for convenience
    local collidingObj
    if ( obj1.myType == "obstacleObject" ) then
        collidingObj = obj2
    else
        collidingObj = obj1
    end

    -- remove "pickableObject" type colliding with he "obstacleObject" type
    if ( collidingObj.myType == "pickableObject" ) then

        -- remove "collidingObj" reference from "screenObjectsTable"
        local screenObjectsTable = composer.getVariable( "screenObjectsTable" )
        for i = #screenObjectsTable, 1, -1 do
            if ( screenObjectsTable[i] == collidingObj ) then
                table.remove( screenObjectsTable, i )
                break
            end
        end

        -- remove "collidingObj" from display
        display.remove( collidingObj )
    end
end













-- OLD CODE --------------------------

-- handle "submarine" and "groundObject" collision
        -- no way to determine who is who, so we write both conditions
        if ( ( obj1.myName == "submarine" and obj2.myName == "groundObject" ) or
             ( obj1.myName == "groundObject" and obj2.myName == "submarine" ) )
		then
			-- remove groundObject from display
			if ( obj1.myName == "groundObject" ) then
				display.remove( obj1 )

			else
				display.remove( obj2 )
			end

			-- remove "groundObject" reference from "screenObjectsTable"
			local screenObjectsTable = composer.getVariable( "screenObjectsTable" )
            for i = #screenObjectsTable, 1, -1 do
                if ( screenObjectsTable[i] == obj1 or screenObjectsTable[i] == obj2 ) then
                    table.remove( screenObjectsTable, i )
                    break
                end
            end

            -- update score
            score = score + 100
			scoreText.text = "Score: " .. score

			-- update sea life
			seaLife = seaLife + 200
			if ( seaLife > seaLifeMax ) then
				seaLife = seaLifeMax
			end

			-- update sea life bar
			seaLifeProgressView:setProgress( seaLife / seaLifeMax )
			 
		-- handle "submarine" and "floatingObject" collision
        -- no way to determine who is who, so we write both conditions
		elseif ( ( obj1.myName == "submarine" and obj2.myName == "floatingObject" ) or
             	 ( obj1.myName == "floatingObject" and obj2.myName == "submarine" ) )
		then
			-- remove floatingObject from display
			if ( obj1.myName == "floatingObject" ) then
				display.remove( obj1 )

			else
				display.remove( obj2 )
			end

            -- remove "floatingObject" reference from "screenObjectsTable"
			local screenObjectsTable = composer.getVariable( "screenObjectsTable" )
            for i = #screenObjectsTable, 1, -1 do
                if ( screenObjectsTable[i] == obj1 or screenObjectsTable[i] == obj2 ) then
                    table.remove( screenObjectsTable, i )
                    break
                end
            end

            -- update score
            score = score + 50
			scoreText.text = "Score: " .. score

			-- update sea life
			seaLife = seaLife + 100
			if ( seaLife > seaLifeMax ) then
				seaLife = seaLifeMax
			end

			-- update sea life bar
			seaLifeProgressView:setProgress( seaLife / seaLifeMax )
			
		-- handle "obstacle" and ("floatingObject" or "groundObject") collision
		-- no way to determine who is who, so we write all conditions
		-- this check is done to avoid losing score on objects that are impossible to pick
		elseif ( ( obj1.myName == "obstacle" and obj2.myName == "floatingObject" ) or
				 ( obj1.myName == "floatingObject" and obj2.myName == "obstacle" ) or
				 ( obj1.myName == "obstacle" and obj2.myName == "groundObject" ) or
				 ( obj1.myName == "groundObject" and obj2.myName == "obstacle" ) )
		then
			-- Remove "ground/floatingObject" from display
			if ( obj1.myName == "floatingObject" or obj1.myName == "groundObject" ) then
				display.remove( obj1 )

			else
				display.remove( obj2 )
			end

            -- remove "ground/floatingObject" reference from "screenObjectsTable"
			local screenObjectsTable = composer.getVariable( "screenObjectsTable" )
            for i = #screenObjectsTable, 1, -1 do
				if ( (screenObjectsTable[i] == obj1 or screenObjectsTable[i] == obj2 ) and
				     ( screenObjectsTable[i].myName == "floatingObject" or screenObjectsTable[i].myName == "groundObject" ) )
				then
                    table.remove( screenObjectsTable, i )
                    break
                end
            end

		-- handle "submarine" and "obstacle" collision
		-- no way to determine who is who, so we write both conditions
        elseif ( ( obj1.myName == "submarine" and obj2.myName == "obstacle" ) or
                 ( obj1.myName == "obstacle" and obj2.myName == "submarine" ) )
        then
			gameOver()
        end























































function M.setGamedata( varName, newValue )

    --[[ 
    NOTE: 
    In Lua doing table[ "foo" ] = 1
        is the same as doing table.foo = 1
    --]]

    -- set variable 
    gamedataTable[ varName ] = newValue

    -- write gamedata to file
    saveGamedata()
end


function M.getGamedata( varName )
    
    --[[ 
    NOTE: 
    In Lua table[ "foo" ]
        is the same as table.foo
    --]]

    -- return the table reference
    return gamedataTable[ varName ]
end


















