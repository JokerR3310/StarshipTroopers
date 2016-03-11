util.AddNetworkString( "WaveResult" )
util.AddNetworkString( "WaveStart" )

GM.RoundEnd = CurTime()

SetGlobalInt("TimeLeft", GM.RoundLength:GetInt())

function GM:OnPreRoundStart( num )
	self:SetGameState(STATE_ROUND_IN_PROGRESS)

	SetGlobalInt("TimeLeft", self.RoundLength:GetInt())

	hook.Call("OnRoundStart", self, num + 1)
end

function GM:OnRoundEnd()
	self:SetGameState(STATE_ROUND_OVER)
	
	RunConsoleCommand("r_cleardecals")
	
	if self:GetRound() == self.RoundLimit:GetInt() then
		MapVote.Start(60, 32)

		for _, v in pairs(player.GetAll()) do
			v:SetTeam( TEAM_SPECTATOR )
			v:KillSilent()
			v:Spectate( OBS_MODE_ROAMING )
			v:CrosshairDisable()
		end
		
		--net.Start("WaveResult")
		--net.WriteInt(winner, 4)
		--net.Broadcast()
	else
		timer.Remove("WaveEndTimer")
		timer.Remove("UpdateWaveTime")
	
		timer.Create("DelayNewWave", self.RoundPostEndTime:GetInt(), 1, function()
			hook.Call("OnPreRoundStart", self, self:GetRound() + 1)
			self:NextRound()
		end)
	end
end

function GM:OnRoundStart(round)
	self.RoundEnd = CurTime() + self.RoundLength:GetInt()
	
	RunConsoleCommand("r_cleardecals")

	net.Start("WaveStart")
	net.WriteInt(self:GetRound(), 8)
	net.Broadcast()
	
	timer.Create("UpdateWaveTime", 1, self.RoundLength:GetInt(), function()
		SetGlobalInt("TimeLeft", math.Clamp(math.Round(self.RoundEnd-CurTime()), 0, GAMEMODE.RoundLength:GetInt()))
	end)

	timer.Create("WaveEndTimer", self.RoundLength:GetInt(), 1, function()
		SetGlobalInt("TimeLeft", 0)
		self:OnRoundEnd()
	end)
end

function GM:OnRoundFail()
	for _, v in pairs(player.GetAll()) do v:SetTeam( TEAM_SPECTATOR ) v:Money_Create() end

	timer.Simple(1, function()
		game.CleanUpMap()
	end)
	
	self:SetGameState(STATE_WAITING_FOR_PLAYERS)
	
	self:SetRound(0)
	
	timer.Remove("WaveEndTimer")
	timer.Remove("UpdateWaveTime")
	
	SetGlobalInt("TimeLeft", self.RoundLength:GetInt())
	
	for _, v in pairs(player.GetAll()) do
		GAMEMODE:ShowTeam(v)
		v:Spawn()
	end
	
	local LoadMap = GAMEMODE.FolderName .. "/gamemode/maps/" .. game.GetMap() .. ".lua"
	
	if file.Exists( LoadMap, "LUA" ) then
		include( LoadMap )
	end
		
	PrintMessage(HUD_PRINTTALK, 'Wave failed and map was restarted.')
end