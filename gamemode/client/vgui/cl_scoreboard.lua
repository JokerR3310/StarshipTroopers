surface.CreateFont( "_ScoreboardTopLabel",{
	font = "Roboto",
	size = 20,
	weight = 600
})

surface.CreateFont( "ScoreboardDefault",{
	font		= "Helvetica",
	size		= 22,
	weight		= 800
})

surface.CreateFont( "ScoreboardDefaultTitle",{
	font		= "Helvetica",
	size		= 32,
	weight		= 800
})

-- Class
local soldier = "hud_elements/class_heavy.png"
local engineer = "hud_elements/class_engineer.png"
local medic = "hud_elements/class_medic.png"
local sniper = "hud_elements/class_sniper.png"
local spec = "hud_elements/class_spectator.png"

local PLAYER_LINE = 
{
	Init = function( self )

		self.AvatarButton = self:Add( "DButton" )
		self.AvatarButton:Dock( LEFT )
		self.AvatarButton:SetSize( 32, 32 )
		self.AvatarButton.DoClick = function()
		surface.PlaySound("buttons/button9.wav")
		local opt = DermaMenu()
			opt:AddOption("Copy SteamID", function() SetClipboardText(self.Player:SteamID()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/tag_blue.png")
			opt:AddOption("Copy Name", function() SetClipboardText(self.Player:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/user_edit.png")
			opt:AddSpacer()
			opt:AddOption("Open Profile", function() self.Player:ShowProfile() surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/world.png")
			opt:Open()
		end

		self.Avatar = vgui.Create( "AvatarImage", self.AvatarButton )
		self.Avatar:SetSize( 32, 32 )
		self.Avatar:SetMouseInputEnabled( false )

		self.Name = self:Add( "DLabel" )
		self.Name:Dock( FILL )
		self.Name:SetFont( "ScoreboardDefault" )
		self.Name:SetColor(Color(238, 238, 238, 255))
		self.Name:DockMargin( 8, 0, 0, 0 )

		self.Mute = self:Add( "DImageButton" )
		self.Mute:SetSize( 32, 32 )
		self.Mute:Dock( RIGHT )

		self.Ping = self:Add( "DLabel" )
		self.Ping:Dock( RIGHT )
		self.Ping:SetWidth( 50 )
		self.Ping:SetFont( "ScoreboardDefault" )
		self.Ping:SetContentAlignment( 5 )

		self.Deaths = self:Add( "DLabel" )
		self.Deaths:Dock( RIGHT )
		self.Deaths:SetWidth( 70 )
		self.Deaths:SetFont( "ScoreboardDefault" )
		self.Deaths:SetContentAlignment( 5 )

		self.Kills = self:Add( "DLabel" )
		self.Kills:Dock( RIGHT )
		self.Kills:SetWidth( 70 )
		self.Kills:SetFont( "ScoreboardDefault" )
		self.Kills:SetContentAlignment( 5 )
		
		self.Class = self:Add( "DImage" )
		self.Class:SetPos(425, 4)
		self.Class:SetSize(32, 32)
		self.Class:SetImage("hud_elements/class_heavy.png")
		self.Class:SetContentAlignment( 5 )

		self:Dock( TOP )
		self:DockPadding( 3, 3, 3, 3 )
		self:SetHeight( 32 + 3*2 )
		self:DockMargin( 2, 0, 2, 2 )
	end,

	Setup = function( self, pl )

		self.Player = pl

		self.Avatar:SetPlayer( pl )
		self.Name:SetText( pl:Nick() )

		self:Think( self )
	end,

	Think = function( self )

		if ( !IsValid( self.Player ) ) then
			self:Remove()
			return
		end
		if ( self.NumCash == nil || self.NumCash != self.Player:GetNWInt( "cash" ) ) then
			self.NumCash	=	self.Player:GetNWInt( "cash" )
			self.Kills:SetText( self.NumCash )
		end

		if ( self.NumDeaths == nil || self.NumDeaths != self.Player:Deaths() ) then
			self.NumDeaths	=	self.Player:Deaths()
			self.Deaths:SetText( self.NumDeaths )
		end

		if ( self.NumPing == nil || self.NumPing != self.Player:Ping() ) then
			self.NumPing	=	self.Player:Ping()
			self.Ping:SetText( self.NumPing )
		end
		
		if player_manager.GetPlayerClass( self.Player ) == "player_soldier" then
			self.Class:SetImage(soldier)
		elseif player_manager.GetPlayerClass( self.Player ) == "player_engineer" then
			self.Class:SetImage(engineer)
		elseif player_manager.GetPlayerClass( self.Player ) == "player_medic" then
			self.Class:SetImage(medic)
		elseif player_manager.GetPlayerClass( self.Player ) == "player_sniper" then
			self.Class:SetImage(sniper)
		end
		
		if ( self.Player:Team() == TEAM_SPECTATOR ) then
			self.Class:SetImage(spec)
		end

		--
		-- Change the icon of the mute button based on state
		--
		if ( self.Muted == nil || self.Muted != self.Player:IsMuted() ) then

			self.Muted = self.Player:IsMuted()
			if ( self.Muted ) then
				self.Mute:SetImage( "icon32/muted.png" )
			else
				self.Mute:SetImage( "icon32/unmuted.png" )
			end

			self.Mute.DoClick = function() self.Player:SetMuted( !self.Muted ) end

		end

		if ( self.Player:Team() == TEAM_CONNECTING ) then
			self:SetZPos( 2000 )
		end

		self:SetZPos( (self.NumCash * -50) + self.NumDeaths )
	end,

	Paint = function( self, w, h )

		if ( !IsValid( self.Player ) ) then
			return
		end

		--
		-- We draw our background a different colour based on the status of the player
		--

		if ( self.Player:Team() == TEAM_SPECTATOR ) then
			draw.RoundedBox( 4, 0, 0, w, h, Color(145, 145, 145, 220))
			return
		end
		
		if ( self.Player:Team() == TEAM_CONNECTING ) then
			draw.RoundedBox( 0, 0, 0, w, h, Color(0, 0, 0, 0)) --Color(200, 200, 200, 220 )
			return
		end

		if  ( !self.Player:Alive() ) then
			draw.RoundedBox( 4, 0, 0, w, h, Color(13, 10, 100, 220))
			return
		end

		if ( self.Player:IsAdmin() ) then
			draw.RoundedBox( 4, 0, 0, w, h, Color(43, 40, 200, 220))
			return
		end

		draw.RoundedBox( 4, 0, 0, w, h, Color(23, 20, 200, 220))

	end,
}

--
-- Convert it from a normal table into a Panel Table based on DPanel
--
PLAYER_LINE = vgui.RegisterTable( PLAYER_LINE, "DPanel" );

--
-- Here we define a new panel table for the scoreboard. It basically consists 
-- of a header and a scrollpanel - into which the player lines are placed.
--
local SCORE_BOARD = 
{
	Init = function( self )

		self.Header = self:Add( "Panel" )
		self.Header:Dock( TOP )
		self.Header:SetHeight( 100 )

		self.Name = self.Header:Add( "DLabel" )
		self.Name:SetFont( "ScoreboardDefaultTitle" )
		self.Name:SetTextColor( Color( 255, 255, 255, 255 ) )
		self.Name:Dock( TOP )
		self.Name:SetHeight( 40 )
		self.Name:SetContentAlignment( 5 )
		self.Name:SetExpensiveShadow( 2, Color( 0, 0, 0, 200 ) )

		self.Scores = self:Add( "DScrollPanel" )
		self.Scores:Dock( FILL )

	end,

	PerformLayout = function( self )

		self:SetSize( 700, ScrH() - 200)
		self:SetPos( ScrW() / 2 - 350, 100)
	end,

	Paint = function( self, w, h )

		draw.SimpleTextOutlined( "Name", "_ScoreboardTopLabel", 120, 84, Color( 228, 228, 228, 255 ), 1, 1, 1, Color( 0, 0, 0, 255 ) )
		draw.SimpleTextOutlined( "Class", "_ScoreboardTopLabel", 440, 84, Color( 228, 228, 228, 255 ), 1, 1, 1, Color( 0, 0, 0, 255 ) )
		draw.SimpleTextOutlined( "Points", "_ScoreboardTopLabel", 508, 84, Color( 228, 228, 228, 255 ), 1, 1, 1, Color( 0, 0, 0, 255 ) )
		draw.SimpleTextOutlined( "Deaths", "_ScoreboardTopLabel", 578, 84, Color( 228, 228, 228, 255 ), 1, 1, 1, Color( 0, 0, 0, 255 ) )
		draw.SimpleTextOutlined( "Ping", "_ScoreboardTopLabel", 640, 84, Color( 228, 228, 228, 255 ), 1, 1, 1, Color( 0, 0, 0, 255 ) )	
	end,

	Think = function( self, w, h )

		self.Name:SetText( GetHostName() )

		--
		-- Loop through each player, and if one doesn't have a score entry - create it.
		--
		local plyrs = player.GetAll()
		for id, pl in pairs( plyrs ) do

			if ( IsValid( pl.ScoreEntry ) ) then continue end

			pl.ScoreEntry = vgui.CreateFromTable( PLAYER_LINE, pl.ScoreEntry )
			pl.ScoreEntry:Setup( pl )

			self.Scores:AddItem( pl.ScoreEntry )
		end		
	end,
}

SCORE_BOARD = vgui.RegisterTable( SCORE_BOARD, "EditablePanel" );

function GM:ScoreboardShow()
	if ( !IsValid( g_Scoreboard ) ) then
		g_Scoreboard = vgui.CreateFromTable( SCORE_BOARD )
	end

	if ( IsValid( g_Scoreboard ) ) then
		g_Scoreboard:Show()
		g_Scoreboard:MakePopup()
		g_Scoreboard:SetKeyboardInputEnabled( false )
	end
end

function GM:ScoreboardHide()
	if ( IsValid( g_Scoreboard ) ) then
		g_Scoreboard:Hide()
	end
end

function GM:HUDDrawScoreBoard()
end