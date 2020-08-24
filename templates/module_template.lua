local M = {}

-- define vars

-- assets dir


-- ----------------------------------------------------------------------------
-- private functions
-- ----------------------------------------------------------------------------




-- ----------------------------------------------------------------------------
-- public functions
-- ----------------------------------------------------------------------------

-- insert in scene:create()
function M.create( group )
    
    -- init vars
    
end

-- insert in scene:show() in "will" phase
function M.showWill()

end

-- insert in scene:show() in "did" phase
function M.showDid()

end

-- insert in scene:hide() in "will" phase
function M.hideWill()

    -- remove Runtime listeners

    -- cancel timers

    -- cancel transitions

end

-- insert in scene:hide() in "did" phase
function M.hideDid()

    -- remove Runtime listeners

    -- cancel timers

    -- cancel transitions

end

-- insert in scene:destroy()
function M.destroy()

    -- dispose loaded audio

end


-- return module table
return M
