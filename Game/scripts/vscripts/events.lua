--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function killer:OnAllPlayersLoaded()
	print("[KILLER] All Players have loaded into the game")

	-- Command for model combining
	ConsoleCommands:SendToAll("dota_combine_models 0")

	-- Command to stop all sounds
	SendToConsole("stopsound")
	SendToServerConsole("stopsound")

	-- Background music
	Timers:CreateTimer(function()
		EmitGlobalSound("Killer.Background")
		return 128
	end)

	self.player_table = {}
	local counter = 0

	for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
		local player_handle = PlayerResource:GetPlayer(nPlayerID)
		if player_handle then
			self.player_table[counter] = player_handle
			player_handle.voted = false
			counter = counter + 1
		end
	end

	self.num_players = counter


	-- Random the killer here
	local player = RandomInt(0, counter - 1)
	print("# User IDs: " .. counter)
	print("Randomed player ID: " .. player)

	self.player_table[player].killer = true

	-- set game_started to true after a couple of seconds

	Timers:CreateTimer(25,function()
		self.game_started = true
	end)

end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in.
]]
function killer:OnHeroInGame(hero)
	print("[KILLER] Hero spawned in game for first time -- " .. hero:GetUnitName())
	local player_id = hero:GetPlayerID()
	print("Hero Self " .. tostring(self))

	if not self.greetPlayers then
		-- At this point a player now has a hero spawned in your map.
		
	    local firstLine = ColorIt("Welcome to ", "green") .. ColorIt("Escape from the Narrow Maze! ", "magenta") .. ColorIt("v1.0", "blue");
	    local secondLine = ColorIt("Developers: ", "green") .. ColorIt("Pizzalol & chrislotix", "orange")
		-- Send the first greeting in 4 secs.
		Timers:CreateTimer(4, function()
	        GameRules:SendCustomMessage(firstLine, 0, 0)
	        GameRules:SendCustomMessage(secondLine, 0, 0)
		end)

		self.greetPlayers = true
	end

	-- Store a reference to the player handle inside this hero handle.
	hero.player = PlayerResource:GetPlayer(player_id)
	-- Store the player's name inside this hero handle.
	hero.playerName = PlayerResource:GetPlayerName(player_id)
	-- Store this hero handle in this table.
	table.insert(self.vPlayers, hero)

	if Testing then
		--Say(nil, "Testing is on.", false)
	end

	print("HELLO TESTING ABILITIES")
	InitAbilities(hero)

	ParticleManager:CreateParticle("particles/rain_fx/econ_rain.vpcf", PATTACH_EYES_FOLLOW, hero)
	EmitGlobalSound("sounds/ambient/soundscapes/light_rain_lp.vsnd")

	hero:AddNewModifier(hero, nil, "modifier_stunned", {})

	local ability = hero:GetAbilityByIndex(0)

	ability:ApplyDataDrivenModifier(hero, hero, "modifier_killer_attack", {})
	ability:ApplyDataDrivenModifier(hero, hero, "modifier_peasant_disarm", {})
end

-- An NPC has spawned somewhere in game.  This includes heroes
function killer:OnNPCSpawned(keys)
	--print("[KILLER] NPC Spawned")
	--PrintTable(keys)
	local npc = EntIndexToHScript(keys.entindex)

	if npc:IsRealHero() and npc.bFirstSpawned == nil then
		npc.bFirstSpawned = true
		killer:OnHeroInGame(npc)
	end
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function killer:OnConnectFull(keys)
	print ('[KILLER] OnConnectFull')
	--PrintTable(keys)
	killer:Capturekiller()

	local entIndex = keys.index+1
	-- The Player entity of the joining user
	local ply = EntIndexToHScript(entIndex)

	-- The Player ID of the joining player
	local playerID = ply:GetPlayerID()

	-- Update the user ID table with this user
	--if ply then
		self.vUserIds[keys.userid] = ply
	--end

	-- Update the Steam ID table
	self.vSteamIds[PlayerResource:GetSteamAccountID(playerID)] = ply

	-- If the player is a broadcaster flag it in the Broadcasters table
	if PlayerResource:IsBroadcaster(playerID) then
		self.vBroadcasters[keys.userid] = 1
		return
	end
end

---------------------------------------------------------------------------
-- Game state change handler
---------------------------------------------------------------------------
function killer:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	print( "OnGameRulesStateChange: " .. nNewState )

	if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		--ShowGenericPopup( "#multiteam_instructions_title", "#multiteam_instructions_body", tostring(self.TEAM_KILLS_TO_WIN), "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )
	end

	if nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		GameRules:GetGameModeEntity():SetThink( "EnsurePlayersOnCorrectTeam", self, 0 )
		GameRules:GetGameModeEntity():SetThink( "BroadcastPlayerTeamAssignments", self, 1 )
		ShowGenericPopup( "#multiteam_instructions_title", "#multiteam_instructions_body", tostring(self.TEAM_KILLS_TO_WIN), "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )

		local et = 1
		if self.bSeenWaitForPlayers then
			et = .01
		end
		Timers:CreateTimer("alljointimer", {
			useGameTime = true,
			endTime = et,
			callback = function()
				if PlayerResource:HaveAllPlayersJoined() then
					killer:PostLoadPrecache()
					killer:OnAllPlayersLoaded()
					return
				end
				return 1
			end})
	end

	if nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		GameRules:GetGameModeEntity():SetThink( "OnThink", self, 1 ) 
	end

	if nNewState >= DOTA_GAMERULES_STATE_POST_GAME then
		statcollection.sendStats({})
	end
end

function killer:PostLoadPrecache()
	--print("[KILLER] Performing Post-Load precache")

	PrecacheUnitByNameAsync("npc_precache_everything", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in Initkiller() but needs to be done before everyone loads in.
]]
function killer:OnFirstPlayerLoaded()
	--print("[KILLER] First Player has loaded")
end

-- Cleanup a player when they leave
function killer:OnDisconnect(keys)
	--print('[KILLER] Player Disconnected ' .. tostring(keys.userid))
	--PrintTable(keys)

	local name = keys.name
	local networkid = keys.networkid
	local reason = keys.reason
	local userid = keys.userid
end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function killer:OnPlayerReconnect(keys)
	--print ( '[KILLER] OnPlayerReconnect' )
	--PrintTable(keys)
end

-- An entity somewhere has been hurt.  This event fires very often with many units so don't do too many expensive
-- operations here
function killer:OnEntityHurt(keys)
	--print("[KILLER] Entity Hurt")
	--PrintTable(keys)
	local attacker = EntIndexToHScript(keys.entindex_attacker)
	local victim = EntIndexToHScript(keys.entindex_killed)
end

-- A player picked a hero
function killer:OnPlayerPickHero(keys)
	--print ('[KILLER] OnPlayerPickHero')
	--PrintTable(keys)

	local heroClass = keys.hero
	local heroEntity = EntIndexToHScript(keys.heroindex)
	local player = EntIndexToHScript(keys.player)
end

-- An entity died
function killer:OnEntityKilled( keys )
	print( '[KILLER] OnEntityKilled Called' )
	--PrintTable( keys )

	-- The Unit that was Killed
	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	-- The Killing entity
	local killerEntity = nil

	if keys.entindex_attacker ~= nil then
		killerEntity = EntIndexToHScript( keys.entindex_attacker )
	end

	if killedUnit:IsRealHero() then
		--print ("KILLEDKILLER: " .. killedUnit:GetName() .. " -- " .. killerEntity:GetName())
		if not killedUnit.death_counter then
			killedUnit.death_counter = 1
		else
			killedUnit.death_counter = killedUnit.death_counter + 1
		end

		-- Disable respawn of the player
		if killedUnit.death_counter >= 3 or self.phase_three_init then
			Timers:CreateTimer(3.1 ,function()
				print("Testing stoning")

				local ability = killedUnit:GetAbilityByIndex(0)
				print(killedUnit:GetUnitName())

				ability:ApplyDataDrivenModifier(killedUnit, killedUnit, "modifier_killer_vote_dead", {})
			end)
		end
	end
end