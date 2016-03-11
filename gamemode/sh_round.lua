GM.Round = 0

function GM:GetRound()
	return self.Round
end

if SERVER then
	util.AddNetworkString( "Wave" )
	
	function GM:SetRound(num)
		self.Round = num
		net.Start("Wave")
		net.WriteInt(num, 8)
		net.Broadcast()
	end

	function GM:NextRound()
		self:SetRound(self.Round + 1)
	end
else
	function GM.ReceiveRoundResult()-- length )
		--surface.PlaySound("music/HL2_song15.mp3")
		--surface.PlaySound("music/stingers/HL1_stinger_song8.mp3")
		--hook.Call("OnRoundEnd")
		print("SOUND HERE!!!")
	end
	net.Receive("WaveResult", GM.ReceiveRoundResult)

	function GM.ReceiveRound(len)
		GAMEMODE.Round = net.ReadInt(8)
	end
	net.Receive("Wave", GM.ReceiveRound)

	function GM.NetRoundStart(len)
		hook.Call("OnRoundStart", GAMEMODE, net.ReadInt(8))
	end
	net.Receive("WaveStart", GM.NetRoundStart)
end