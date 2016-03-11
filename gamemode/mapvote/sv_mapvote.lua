util.AddNetworkString("RAM_MapVoteStart")
util.AddNetworkString("RAM_MapVoteUpdate")
util.AddNetworkString("RAM_MapVoteCancel")

--MapVote.Continued = false

net.Receive("RAM_MapVoteUpdate", function(len, ply)
    if(MapVote.Allow) then
        if(IsValid(ply)) then
            local update_type = net.ReadUInt(3)
            
            if(update_type == MapVote.UPDATE_VOTE) then
                local map_id = net.ReadUInt(32)
                
                if(MapVote.CurrentMaps[map_id]) then
                    MapVote.Votes[ply:SteamID()] = map_id
                    
                    net.Start("RAM_MapVoteUpdate")
                        net.WriteUInt(MapVote.UPDATE_VOTE, 3)
                        net.WriteEntity(ply)
                        net.WriteUInt(map_id, 32)
                    net.Broadcast()
                end
            end
        end
    end
end)

function MapVote.Start(length, limit)
    length = length or 60
    limit = limit or 24
	
    local maps = file.Find("maps/*.bsp", "GAME")
	--[[
	local info = file.Read(GAMEMODE.Folder.."/"..GAMEMODE.FolderName..".txt", "GAME")
	
	if (info) then
		local info = util.KeyValuesToTable(info)
		prefix = info.maps
		print(prefix)
	end
    ]]
    local vote_maps = {}
    
    local amt = 0
	
	for k, map in RandomPairs(maps) do
        local mapstr = map:sub(1, -5):lower()
		
		--if(string.find(map, "stg_")) then -- if(string.find(map, prefix)) then --
		if(string.StartWith(map, "stg_")) then
			vote_maps[#vote_maps + 1] = map:sub(1, -5)
			amt = amt + 1
		end

        if(limit and amt >= limit) then break end
    end
    
    net.Start("RAM_MapVoteStart")
        net.WriteUInt(#vote_maps, 32)
        
        for i = 1, #vote_maps do
            net.WriteString(vote_maps[i])
        end
        
        net.WriteUInt(length, 32)
    net.Broadcast()
    
    MapVote.Allow = true
    MapVote.CurrentMaps = vote_maps
    MapVote.Votes = {}
    
    timer.Create("RAM_MapVote", length, 1, function()
        MapVote.Allow = false
        local map_results = {}
        
        for k, v in pairs(MapVote.Votes) do
            if(not map_results[v]) then
                map_results[v] = 0
            end
            
            for k2, v2 in pairs(player.GetAll()) do
                if(v2:SteamID() == k) then
					map_results[v] = map_results[v] + 1
                end
            end
            
        end
        
        local winner = table.GetWinningKey(map_results) or 1
        
        net.Start("RAM_MapVoteUpdate")
            net.WriteUInt(MapVote.UPDATE_WIN, 3)
            
            net.WriteUInt(winner, 32)
        net.Broadcast()
        
        local map = MapVote.CurrentMaps[winner]

        timer.Simple(4, function()
            hook.Run("MapVoteChange", map)
            RunConsoleCommand("changelevel", map)
        end)
    end)
end

function MapVote.Cancel()
    if MapVote.Allow then
        MapVote.Allow = false

        net.Start("RAM_MapVoteCancel")
        net.Broadcast()

        timer.Remove("RAM_MapVote")
    end
end