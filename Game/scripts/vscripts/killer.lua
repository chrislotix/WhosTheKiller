--print ('[KILLER] killer.lua' )

ENABLE_HERO_RESPAWN = true              -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = false             -- Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = true        -- Should we let people select the same hero as each other

HERO_SELECTION_TIME = 10             -- How long should we let people select their hero?
PRE_GAME_TIME = 0                    -- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 60.0                   -- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 60.0                 -- How long should it take individual trees to respawn after being cut down/destroyed?

GOLD_PER_TICK = 4                     -- How much gold should players get per tick?
GOLD_TICK_TIME = 2                      -- How long should we wait in seconds between gold ticks?

RECOMMENDED_BUILDS_DISABLED = true     -- Should we disable the recommened builds for heroes (Note: this is not working currently I believe)
CAMERA_DISTANCE_OVERRIDE = 1400.0        -- How far out should we allow the camera to go?  1134 is the default in Dota

MINIMAP_ICON_SIZE = 1                   -- What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1             -- What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1              -- What icon size should we use for runes?

RUNE_SPAWN_TIME = 120                    -- How long in seconds should we wait between rune spawns?
CUSTOM_BUYBACK_COST_ENABLED = true      -- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = true  -- Should we use a custom buyback time?
BUYBACK_ENABLED = false                 -- Should we allow people to buyback when they die?

DISABLE_FOG_OF_WAR_ENTIRELY = false     -- Should we disable fog of war entirely for both teams?
										-- NOTE: This won't reveal particle effects for everyone. You need to create vision dummies for that.

--USE_STANDARD_DOTA_BOT_THINKING = false  -- Should we have bots act like they would in Dota? (This requires 3 lanes, normal items, etc)
USE_STANDARD_HERO_GOLD_BOUNTY = false    -- Should we give gold for hero kills the same as in Dota, or allow those values to be changed?

USE_CUSTOM_TOP_BAR_VALUES = true        -- Should we do customized top bar values or use the default kill count per team?
TOP_BAR_VISIBLE = false                  -- Should we display the top bar score/count at all?
SHOW_KILLS_ON_TOPBAR = true             -- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals)  Requires USE_CUSTOM_TOP_BAR_VALUES

ENABLE_TOWER_BACKDOOR_PROTECTION = false  -- Should we enable backdoor protection for our towers?
REMOVE_ILLUSIONS_ON_DEATH = false       -- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = false             -- Should we disable the gold sound when players get gold?

END_GAME_ON_KILLS = false                -- Should the game end after a certain number of kills?
KILLS_TO_END_GAME_FOR_TEAM = 50         -- How many kills for a team should signify an end of game?

USE_CUSTOM_HERO_LEVELS = true           -- Should we allow heroes to have custom levels?
MAX_LEVEL = 1                          -- What level should we let heroes get to?
USE_CUSTOM_XP_VALUES = false             -- Should we use custom XP values to level up heroes, or the default Dota numbers?

Testing = false
OutOfWorldVector = Vector(11000, 11000, -200)

if not Testing then
  statcollection.addStats({
    modID = '7c594d0455b8be7efad0ab04f4aaf539'
  })
end

-- Fill this table up with the required XP per level if you want to change it
--XP_PER_LEVEL_TABLE = {}
--for i=1,MAX_LEVEL do
--	XP_PER_LEVEL_TABLE[i] = i * 100
--end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
if killer == nil then
	killer = class({})
end


---------------------------------------------------------------------------
-- Initializer
---------------------------------------------------------------------------
function killer:Initkiller()
	print( "Multiteam Example addon is loaded." )
	killer = self

	self.m_TeamColors = {}
	self.m_TeamColors[DOTA_TEAM_GOODGUYS] = { 255, 0, 0 }
	self.m_TeamColors[DOTA_TEAM_BADGUYS] = { 0, 255, 0 }
	self.m_TeamColors[DOTA_TEAM_CUSTOM_1] = { 0, 0, 255 }
	self.m_TeamColors[DOTA_TEAM_CUSTOM_2] = { 255, 128, 64 }
	self.m_TeamColors[DOTA_TEAM_CUSTOM_3] = { 255, 255, 0 }
	self.m_TeamColors[DOTA_TEAM_CUSTOM_4] = { 128, 255, 0 }
	self.m_TeamColors[DOTA_TEAM_CUSTOM_5] = { 128, 0, 255 }
	self.m_TeamColors[DOTA_TEAM_CUSTOM_6] = { 255, 0, 128 }
	self.m_TeamColors[DOTA_TEAM_CUSTOM_7] = { 0, 255, 255 }
	self.m_TeamColors[DOTA_TEAM_CUSTOM_8] = { 255, 255, 255 }

	self.m_VictoryMessages = {}
	self.m_VictoryMessages[DOTA_TEAM_GOODGUYS] = "#VictoryMessage_GoodGuys"
	self.m_VictoryMessages[DOTA_TEAM_BADGUYS] = "#VictoryMessage_BadGuys"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_1] = "#VictoryMessage_Custom1"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_2] = "#VictoryMessage_Custom2"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_3] = "#VictoryMessage_Custom3"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_4] = "#VictoryMessage_Custom4"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_5] = "#VictoryMessage_Custom5"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_6] = "#VictoryMessage_Custom6"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_7] = "#VictoryMessage_Custom7"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_8] = "#VictoryMessage_Custom8"

	-- Initialized tables for tracking state
	self.vUserIds = {}
	self.vSteamIds = {}
	self.vBots = {}
	self.vBroadcasters = {}

	self.vPlayers = {}

	self.bSeenWaitForPlayers = false

	self.m_GatheredShuffledTeams = {}
	self.m_PlayerTeamAssignments = {}
	self.m_NumAssignedPlayers = 0

	self.TEAM_KILLS_TO_WIN = 15
	self.all_players_joined = true
	self.phase_one_init = false
	self.phase_two_init = false
	self.phase_two_punish = false
	self.phase_three_init = false

	-- Change random seed
	local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
	math.randomseed(tonumber(timeTxt))	

	if RECOMMENDED_BUILDS_DISABLED then
		GameRules:GetGameModeEntity():SetHUDVisible( DOTA_HUD_VISIBILITY_SHOP_SUGGESTEDITEMS, false )
	end

	---------------------------------------------------------------------------

	self:GatherValidTeams()

	-- Show the ending scoreboard immediately
	GameRules:SetCustomGameEndDelay( 0 )
	GameRules:SetCustomVictoryMessageDuration( 0 )
	GameRules:SetHideKillMessageHeaders( true )

	--ListenToGameEvent( "dota_team_kill_credit", Dynamic_Wrap( killer, 'OnTeamKillCredit' ), self )
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( killer, 'OnGameRulesStateChange' ), self )
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(killer, 'OnConnectFull'), self)
	ListenToGameEvent('entity_killed', Dynamic_Wrap(killer, 'OnEntityKilled'), self)
	ListenToGameEvent('player_disconnect', Dynamic_Wrap(killer, 'OnDisconnect'), self)
	ListenToGameEvent('player_changename', Dynamic_Wrap(killer, 'OnPlayerChangedName'), self)
	ListenToGameEvent('entity_hurt', Dynamic_Wrap(killer, 'OnEntityHurt'), self)
	--ListenToGameEvent('player_connect', Dynamic_Wrap(killer, 'PlayerConnect'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(killer, 'OnGameRulesStateChange'), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(killer, 'OnNPCSpawned'), self)
	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(killer, 'OnPlayerPickHero'), self)
	--ListenToGameEvent('dota_team_kill_credit', Dynamic_Wrap(killer, 'OnTeamKillCredit'), self)
	ListenToGameEvent("player_reconnected", Dynamic_Wrap(killer, 'OnPlayerReconnect'), self)


	-- This is for testing scaleform --
	--register the 'BuyAbilityPoint' command in our console
	Convars:RegisterCommand( "BuyAbilityPoint", function(name, p)
	    --get the player that sent the command
	    local cmdPlayer = Convars:GetCommandClient()
	    if cmdPlayer then 
	        --if the player is valid, execute PlayerBuyAbilityPoint
	        return self:PlayerBuyAbilityPoint( cmdPlayer, p ) 
	    end
	end, "A player buys an ability point", 0 )
end

mode = nil

-- This function is called as the first player loads and sets up the killer parameters
function killer:Capturekiller()
	if mode == nil then
		-- Set killer parameters
		mode = GameRules:GetGameModeEntity()
		mode:SetRecommendedItemsDisabled( RECOMMENDED_BUILDS_DISABLED )
		mode:SetCameraDistanceOverride( CAMERA_DISTANCE_OVERRIDE )
		mode:SetCustomBuybackCostEnabled( CUSTOM_BUYBACK_COST_ENABLED )
		mode:SetCustomBuybackCooldownEnabled( CUSTOM_BUYBACK_COOLDOWN_ENABLED )
		mode:SetBuybackEnabled( BUYBACK_ENABLED )
		mode:SetTopBarTeamValuesOverride ( USE_CUSTOM_TOP_BAR_VALUES )
		mode:SetTopBarTeamValuesVisible( TOP_BAR_VISIBLE )
		mode:SetUseCustomHeroLevels ( USE_CUSTOM_HERO_LEVELS )
		mode:SetCustomHeroMaxLevel ( MAX_LEVEL )
		mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )

		GameRules:SetPreGameTime(PRE_GAME_TIME) 
		GameRules:SetHeroSelectionTime(HERO_SELECTION_TIME)
		GameRules:SetHideKillMessageHeaders( true )
		GameRules:SetSameHeroSelectionEnabled( ALLOW_SAME_HERO_SELECTION )

		GameRules:SetTimeOfDay(0) -- Set it to be midnight

		mode:SetHUDVisible(0, false) -- Clock
		mode:SetHUDVisible(2, false) -- Scoreboard
		mode:SetHUDVisible(6, false) -- Shop
		mode:SetHUDVisible(9, false) -- Courier
		mode:SetHUDVisible(10, false) -- Fortification
		mode:SetHUDVisible(11, false) -- Gold
		mode:SetHUDVisible(12, false) -- Suggested items

		--mode:SetBotThinkingEnabled( USE_STANDARD_DOTA_BOT_THINKING )
		mode:SetTowerBackdoorProtectionEnabled( ENABLE_TOWER_BACKDOOR_PROTECTION )

		--mode:SetFogOfWarDisabled(DISABLE_FOG_OF_WAR_ENTIRELY)
		mode:SetGoldSoundDisabled( DISABLE_GOLD_SOUNDS )
		mode:SetRemoveIllusionsOnDeath( REMOVE_ILLUSIONS_ON_DEATH )

		self:OnFirstPlayerLoaded()
	end
end

---------------------------------------------------------------------------
-- Update player labels and the scoreboard
---------------------------------------------------------------------------
function killer:OnThink()
	GameRules:SetTimeOfDay(0) -- Set it to be midnight constantly

	for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
		self:MakeLabelForPlayer( nPlayerID )
	end
	
	local phase_one = self:PhaseOne()

	if phase_one == 2 then
		local phase_two = self:PhaseTwo()
		
		if phase_two == 2 and not self.phase_three_init then
			self:PhaseThree()
		end
	end
		
	return 1
end

---------------------------------------------------------------------------
-- Scaleform function testing
---------------------------------------------------------------------------

function killer:PlayerBuyAbilityPoint( player, p)
    --NOTE: p contains our parameter (the '1') now (as a string not a number), we just don't use it
    
    --determine a price for the ability point, you probably should do this globally
    local price = 200;
    
    --get the player's ID
    local pID = player:GetPlayerID()
    
    --get the players current gold
    local playerGold = PlayerResource:GetGold( pID )
    
    --check if the player has enough gold, checking extra doesn't hurt
    if playerGold >= price then
        --spend the gold
        PlayerResource:SpendGold( pID, price, 0 )
        --add the ability point to the player
        local playerHero = player:GetAssignedHero()
        playerHero:SetAbilityPoints(playerHero:GetAbilityPoints() + 1)
    end

    --Fire the event. The second parameter is an object with all the event's parameters as properties
    --We have to get the player's gold again, because we have deducted the price from it since the last time we got it.
    FireGameEvent('cgm_player_gold_changed', { player_ID = pID, gold_amount = PlayerResource:GetGold( pID ) })
end

---------------------------------------------------------------------------
-- Calculates the duration of the first phase
-- Keeps track of the remaining lives of the players
---------------------------------------------------------------------------
function killer:PhaseOne()
	-- End time = users * 1
	self.end_time = self.end_time or (self.num_players * 45 + 60) -- Seconds until phase two

	--print("End time: " .. self.end_time)
	-- While the phase one hasnt started keep checking if all players joined
	if not self.phase_one_init then
		self.all_players_joined = true
		for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
			local player = PlayerResource:GetPlayer(nPlayerID)

			if player then
				local player_hero = player:GetAssignedHero()

				if not player_hero then
					self.all_players_joined = false
				end
			end
		end
	end

	-- If all players joined then do a countdown until the start of the game
	if self.all_players_joined and not self.phase_one_init then
		sendAMsg("All players joined, starting match in 10")
		local starting_in = 5
		Timers:CreateTimer(5,function()
			if starting_in > 0 then
				sendAMsg(starting_in .. "...")
				starting_in = starting_in - 1
				return 1
			else
				for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
					local player = PlayerResource:GetPlayer(nPlayerID)

					if player then
						local player_hero = player:GetAssignedHero()

						if player_hero then
							player_hero:RemoveModifierByName("modifier_stunned")

							if player.killer then
								local killer_spawn = Entities:FindByName(nil, "killer_spawn")

								player.killer_unit = CreateUnitByName("killer", killer_spawn:GetAbsOrigin(), true, player_hero, player_hero, player_hero:GetTeamNumber())
								player.killer_unit:SetControllableByPlayer(nPlayerID, true)
							end
						end
					end					
				end
				self.game_started = true
			end
		end)
		

		self.phase_one_init = true
		self.all_players_joined = false -- Set it to false so that this isnt run again
	elseif not self.phase_one_init then
		sendAMsg("Waiting for players to join the game")		
	end

	if self.end_time >= 0 then
		local minutes = math.floor(self.end_time / 60)
		local seconds = self.end_time % 60

		--print("Minutes: " .. minutes)
		--print("Seconds: " .. seconds)

		local sortedTeams = {}
		for _, team_id in pairs( self.m_GatheredShuffledTeams ) do
			--print("Updating score")
			local lives_remaining = 0
			if(PlayerResource:GetNthPlayerIDOnTeam(team_id, 1) ~= -1) then
				local player_id = PlayerResource:GetNthPlayerIDOnTeam(team_id, 1)
				local player_hero = PlayerResource:GetPlayer(player_id):GetAssignedHero()
				if player_hero then
					lives_remaining = 3 - player_hero:GetDeaths()
				end
			end
			table.insert( sortedTeams, { teamID = team_id, teamScore = lives_remaining } )
		end

		-- reverse-sort by score
		table.sort( sortedTeams, function(a,b) return ( a.teamScore > b.teamScore ) end )

		UTIL_ResetMessageTextAll()
		UTIL_MessageTextAll( "Time remaining" .. " " .. minutes .. ":" .. seconds, 255, 255, 255, 255 )
		UTIL_MessageTextAll( "Lives remaining", 255, 255, 255, 255 )
		UTIL_MessageTextAll( "#ScoreboardSeparator", 255, 255, 255, 255 )
		for _, t in pairs( sortedTeams ) do
			local clr = self:ColorForTeam( t.teamID )
			--UTIL_MessageTextAll_WithContext( "#ScoreboardRow", clr[1], clr[2], clr[3], 255, { team_id = t.teamID, value = t.teamScore } )
			if(PlayerResource:GetNthPlayerIDOnTeam(t.teamID, 1) ~= -1) then
				name = PlayerResource:GetPlayerName(PlayerResource:GetNthPlayerIDOnTeam(t.teamID, 1))
				UTIL_MessageTextAll(t.teamScore.."\t"..name, clr[1], clr[2], clr[3], 255)
			end
		end

		print(self.game_started)
		-- Count down only if the game is in progress
		if self.phase_one_init or self.game_started then
			self.end_time = self.end_time - 1
		end

		return 1
	end

	return 2 -- Do phase two logic
end

---------------------------------------------------------------------------
-- Calculates the duration of the second phase
-- Lasts until every living player voted or until the voting phase expires
---------------------------------------------------------------------------
function killer:PhaseTwo( keys )
	self.phase_two_init = self.phase_two_init
	self.phase_two_end_time = self.phase_two_end_time or 63
	self.vote_limit = self.vote_limit or 0

	local minutes = math.floor(self.phase_two_end_time / 60)
	local seconds = self.phase_two_end_time % 60
	
	-- Check if phase two started before
	if self.phase_two_init then
		local counter = 0

		-- If it did then count how many players voted
		for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
			local player = PlayerResource:GetPlayer(nPlayerID)

			if player then
				local player_hero = player:GetAssignedHero() 

				if player_hero and player_hero:HasModifier("modifier_killer_vote") then
					counter = counter + 1
				end
			end			
		end

		-- If all the living players voted then end the voting phase early
		if counter == self.vote_limit then
			return 2
		end
	else
		-- If its the first time we are in phase two then track that
		self.phase_two_init = true

		-- Kill the killer unit
		--[[for _,v in ipairs(self.vUserIds) do
			if v.killer_unit then
				v.killer_unit:ForceKill(true)
				break
			end
		end]]

		for _,visage in ipairs(Entities:FindAllByModel("models/heroes/visage/visage.vmdl")) do
			visage:ForceKill(true)
		end

		sendAMsg("Voting phase")
		Timers:CreateTimer(1, function()
			sendAMsgTime("Who is the killer?", 5)
		end)

		-- Create voting dummies for all the living people
		for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
			local player = PlayerResource:GetPlayer(nPlayerID) 

			if player then
				local player_hero = player:GetAssignedHero()

				local dummy_position = Entities:FindByName(nil, "voting_circle" .. nPlayerID)
				local player_position = Entities:FindByName(nil, "voting_spawn")

				--player_hero:SetAbsOrigin(player_position:GetAbsOrigin())
				if not player_hero:HasModifier("modifier_killer_vote_dead") then
					FindClearSpaceForUnit(player_hero, player_position:GetAbsOrigin(), true)
				end
				
				player_hero:AddNewModifier(player_hero, nil, "modifier_stunned", {duration = 5})
				player.voting_dummy = CreateUnitByName("npc_voting_dummy", dummy_position:GetAbsOrigin(), true, player_hero, player_hero, player_hero:GetTeamNumber())

				local teamID = PlayerResource:GetTeam( nPlayerID )
				local color = self:ColorForTeam( teamID )
				player.voting_dummy:SetCustomHealthLabel( PlayerResource:GetPlayerName(nPlayerID), color[1], color[2], color[3] )

				local ability = player_hero:GetAbilityByIndex(0)
				ability:ApplyDataDrivenModifier(player_hero, player.voting_dummy, "modifier_voting_dummy", {})

				-- Disable all abilities during the voting phase
				for i = 0, 3 do
					player_hero:GetAbilityByIndex(i):SetActivated(false)
				end

				if player_hero:IsAlive() and not player_hero:HasModifier("modifier_killer_vote_dead") then
					self.vote_limit = self.vote_limit + 1
				end
			end
		end


		-- Check all the alive heroes and spawn a voting circle for each of them
		-- Initialize the vote limit
	end

	-- Reset the text field
	UTIL_ResetMessageTextAll()

	-- If the time limit expires then set the heroes that havent voted to count as failed votes
	-- Start phase 3
	if self.phase_two_end_time < 0 or self.phase_three_init then
		--print("testing punishment")
		if not self.phase_two_punish then
			--print("running punishment")
			for i = 0, self.num_players-1 do
				local player_hero = self.player_table[i]:GetAssignedHero()
				if not self.player_table[i].voted then

					print(PlayerResource:GetPlayerName(self.player_table[i]:GetPlayerID()) .. " voted!")
					local ability = player_hero:GetAbilityByIndex(0)

					ability:ApplyDataDrivenModifier(player_hero, player_hero, "modifier_killer_vote_dead", {})
				end
			end
		end

		self.phase_two_punish = true
		return 2
	end
	-- Show the voting timer
	UTIL_MessageTextAll( "Killer vote", 255, 255, 255, 255 )
	UTIL_MessageTextAll( "Time remaining" .. " " .. minutes .. ":" .. seconds, 255, 255, 255, 255 )

	self.phase_two_end_time = self.phase_two_end_time - 1

	return 1
end

-- Phase Three: Killer escapes or is killed
-- Apply a modifier for the dead players on the living ones so that they can spectate
function killer:PhaseThree( keys )
	self.phase_three_init = true
	print("Entering phase three")
	UTIL_ResetMessageTextAll() -- Remove the phase two timer
	local phase_three_position = Entities:FindByName(nil, "phase_three_start")

	local end_game_portal_position = Entities:FindByName(nil, "end_game_portal"):GetAbsOrigin()

	local end_game_portal = CreateUnitByName("npc_dummy_unit", end_game_portal_position, false, nil, nil, DOTA_TEAM_GOODGUYS)
	end_game_portal:GetAbilityByIndex(0):SetLevel(1)

	for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
		local player = PlayerResource:GetPlayer(nPlayerID)
		local found_killer = false

		if player then
			local player_hero = player:GetAssignedHero()
			local ability = player_hero:GetAbilityByIndex(0)

			ability:ApplyDataDrivenModifier(player_hero, player_hero, "modifier_peasant_clearvision_aura", {})

			GameRules:AddMinimapDebugPoint(nPlayerID, end_game_portal_position, 255, 0, 0, 300, 3.0)

			-- Check if the player found the killer
			for _,player_handle in ipairs(self.player_table) do
				if player_handle.killer and player_handle.killer_table then
					for _,hero in ipairs(player_handle.killer_table) do
						if hero == player_hero then
							found_killer = true
						end
					end
				end
			end

			-- If the hero found the killer then remove the pertrification and disarm
			if found_killer and not player.killer then
				--Say(player_hero, "You found the killer!", true)
				--Say(player_hero, "Prevent him from escaping and claim your freedom!", true)
				Timers:CreateTimer(5,function()
					player_hero:RemoveModifierByName("modifier_killer_vote")
					player_hero:RemoveModifierByName("modifier_peasant_disarm")
					player_hero:RemoveModifierByName("modifier_killer_attack")
					player_hero:RemoveModifierByName("modifier_killer_vote_dead")
					FindClearSpaceForUnit(player_hero, phase_three_position:GetAbsOrigin(), true)
				end)
			end

			-- If this is the owner of the killer then apply the end game modifier
			if player.killer then
				local ability = player_hero:GetAbilityByIndex(0) 
				ability:ApplyDataDrivenModifier(player_hero, player_hero, "modifier_killer_end_game", {})

				--Say(player_hero, "You have been found out!", true)
				--Say(player_hero, "Escape to the exit portal before the fallen heroes get to you!", true)

				Timers:CreateTimer(5,function()
					player_hero:RemoveModifierByName("modifier_killer_vote")
					player_hero:RemoveModifierByName("modifier_killer_attack")
					player_hero:RemoveModifierByName("modifier_killer_vote_dead")
				end)
			end

			-- Remove the voting dummy
			player.voting_dummy:ForceKill(true)
		end
	end

	Say(nil, "The killer has been revealed!", false)
	Say(nil, "Stop the killer from escaping and claim your freedom!", false)
	Say(nil, "Everyone but the killer is now able to attack.", false)
end