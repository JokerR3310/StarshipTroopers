RTV = RTV or {}

RTV.VotemapCom = { "!votemap", "/votemap" }

RTV.SettingsCom = { "!settings", "/settings" }

RTV.ClassCom = 	{ "!class", "/class" }

RTV.TotalVotes = 0

RTV.Wait = 6 -- The wait time in seconds. This is how long a player has to wait before voting when the map changes. 

RTV._ActualWait = CurTime() + RTV.Wait

RTV.PlayerCount = 1

function RTV.ShouldChange()
	return RTV.TotalVotes >= math.Round(#player.GetAll()*0.66)
end

function RTV.RemoveVote()
	RTV.TotalVotes = math.Clamp( RTV.TotalVotes - 1, 0, math.huge )
end

function RTV.Start()
	PrintMessage( HUD_PRINTTALK, "The vote has been rocked, map vote imminent")
	timer.Simple(4, function()
		MapVote.Start(nil, nil)
	end)
end

function RTV.AddVote( ply )

	if RTV.CanVote( ply ) then
		RTV.TotalVotes = RTV.TotalVotes + 1
		ply.RTVoted = true
		MsgN( ply:Nick().." has voted to Rock the Vote." )
		PrintMessage( HUD_PRINTTALK, ply:Nick().." has voted to Rock the Vote. ("..RTV.TotalVotes.."/"..math.Round(#player.GetAll()*0.66)..")" )

		if RTV.ShouldChange() then
			RTV.Start()
		end
	end

end

hook.Add( "PlayerDisconnected", "Remove RTV", function( ply )

	if ply.RTVoted then
		RTV.RemoveVote()
	end

	timer.Simple( 0.1, function()

		if RTV.ShouldChange() then
			RTV.Start()
		end

	end )

end )

function RTV.CanVote( ply )
	local plyCount = table.Count(player.GetAll())
	
	if RTV._ActualWait >= CurTime() then
		return false, "You must wait a bit before voting!"
	end

	if GetGlobalBool( "In_Voting" ) then
		return false, "There is currently a vote in progress!"
	end

	if ply.RTVoted then
		return false, "You have already voted to Rock the Vote!"
	end

	if RTV.ChangingMaps then
		return false, "There has already been a vote, the map is going to change!"
	end
	if plyCount < RTV.PlayerCount then
        return false, "You need more players before you can rock the vote!"
    end

	return true

end

function RTV.StartVote( ply )

	local can, err = RTV.CanVote(ply)

	if not can then
		ply:PrintMessage( HUD_PRINTTALK, err )
		return
	end

	RTV.AddVote( ply )

end

--concommand.Add( "rtv_start", RTV.StartVote )

hook.Add( "PlayerSay", "Chat Commands", function( ply, text )
	if table.HasValue( RTV.VotemapCom, string.lower(text) ) then
		RTV.StartVote( ply )
		return ""
	elseif table.HasValue( RTV.SettingsCom, string.lower(text) ) then
		GAMEMODE:ShowHelp( ply )
		return ""
	elseif table.HasValue( RTV.ClassCom, string.lower(text) ) then
		GAMEMODE:ShowTeam( ply )
		return ""
	end
end)