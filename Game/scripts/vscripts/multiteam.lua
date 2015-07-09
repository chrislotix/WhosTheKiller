---------------------------------------------------------------------------
-- Scan the map to see which teams have spawn points
---------------------------------------------------------------------------
function killer:GatherValidTeams()
--	print( "GatherValidTeams:" )

	local foundTeams = {}
	for _, playerStart in pairs( Entities:FindAllByClassname( "info_player_start_dota" ) ) do
		foundTeams[  playerStart:GetTeam() ] = true
	end

	print( "GatherValidTeams - Found spawns for a total of " .. TableCount(foundTeams) .. " teams" )
	
	local foundTeamsList = {}
	for t, _ in pairs( foundTeams ) do
		table.insert( foundTeamsList, t )
	end

	self.m_GatheredShuffledTeams = foundTeamsList --ShuffledList( foundTeamsList )

	print( "Final shuffled team list:" )
	for _, team in pairs( self.m_GatheredShuffledTeams ) do
		print( " - " .. team .. " ( " .. GetTeamName( team ) .. " )" )
	end
end


---------------------------------------------------------------------------
-- Assign all real players to a team
---------------------------------------------------------------------------
function killer:EnsurePlayersOnCorrectTeam()
--	print( "Assigning players to teams..." )
	--[[for playerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
		local teamReassignment = self:GetTeamReassignmentForPlayer( playerID )
		if nil ~= teamReassignment then
			print( " - Player " .. playerID .. " reassigned to team " .. teamReassignment )
			PlayerResource:SetCustomTeamAssignment( playerID, teamReassignment )
			local player_hero = PlayerResource:GetPlayer(playerID):GetAssignedHero()

			if player_hero then
				player_hero:SetTeam(teamReassignment)
			end
		end
	end
	
	return 1 -- Check again later in case more players spawn]]

	for playerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
		local teamReassignment = self:GetTeamReassignmentForPlayer( playerID )
		if nil ~= teamReassignment then
			print( " - Player " .. playerID .. " reassigned to team " .. teamReassignment )
			PlayerResource:SetCustomTeamAssignment( playerID, teamReassignment )

			local player_hero = PlayerResource:GetPlayer(playerID):GetAssignedHero()

			if player_hero then
				player_hero:SetTeam(teamReassignment)
			end
		end
	end
	
	return 1 -- Check again later in case more players spawn
end

---------------------------------------------------------------------------
-- Get the color associated with a given teamID
---------------------------------------------------------------------------
function killer:ColorForTeam( teamID )
	local color = self.m_TeamColors[ teamID ]
	if color == nil then
		color = { 255, 255, 255 } -- default to white
	end
	return color
end


---------------------------------------------------------------------------
-- Determine a good team assignment for the next player
---------------------------------------------------------------------------
function killer:GetTeamReassignmentForPlayer( playerID )
	if #self.m_GatheredShuffledTeams == 0 then
		return nil
	end

	if nil == PlayerResource:GetPlayer( playerID ) then
		return nil -- no player yet
	end
	
	-- see if we've already assigned the player	
	local existingAssignment = self.m_PlayerTeamAssignments[ playerID ]
	if existingAssignment ~= nil then
		if existingAssignment == PlayerResource:GetTeam( playerID ) then
			return nil -- already assigned to this team and they're still on it
		else
			return existingAssignment -- something else pushed them out of the desired team - set it back
		end
	end

	-- haven't assigned this player to a team yet
	print( "m_NumAssignedPlayers = " .. self.m_NumAssignedPlayers )
	
	-- If the number of players per team doesn't divide evenly (ie. 10 players on 4 teams => 2.5 players per team)
	-- Then this floor will round that down to 2 players per team
	-- If you want to limit the number of players per team, you could just set this to eg. 1
	local playersPerTeam = math.floor( DOTA_MAX_TEAM_PLAYERS / #self.m_GatheredShuffledTeams )
	print( "playersPerTeam = " .. playersPerTeam )

	local teamIndexForPlayer = math.floor( self.m_NumAssignedPlayers / playersPerTeam )
	print( "teamIndexForPlayer = " .. teamIndexForPlayer )

	-- Then once we get to the 9th player from the case above, we need to wrap around and start assigning to the first team
	if teamIndexForPlayer >= #self.m_GatheredShuffledTeams then
		teamIndexForPlayer = teamIndexForPlayer - #self.m_GatheredShuffledTeams
		print( "teamIndexForPlayer => " .. teamIndexForPlayer )
	end
	
	teamAssignment = self.m_GatheredShuffledTeams[ 1 + teamIndexForPlayer ]
	print( "teamAssignment = " .. teamAssignment )

	self.m_PlayerTeamAssignments[ playerID ] = teamAssignment

	self.m_NumAssignedPlayers = self.m_NumAssignedPlayers + 1

	return teamAssignment
end


---------------------------------------------------------------------------
-- Put a label over a player's hero so people know who is on what team
---------------------------------------------------------------------------
function killer:MakeLabelForPlayer( nPlayerID )
	if not PlayerResource:HasSelectedHero( nPlayerID ) then
		return
	end

	local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
	if hero == nil then
		return
	end

	local teamID = PlayerResource:GetTeam( nPlayerID )
	local color = self:ColorForTeam( teamID )
	hero:SetCustomHealthLabel( PlayerResource:GetPlayerName(nPlayerID), color[1], color[2], color[3] )
end


---------------------------------------------------------------------------
-- Tell everyone the team assignments during hero selection
---------------------------------------------------------------------------
function killer:BroadcastPlayerTeamAssignments()
	print( "BroadcastPlayerTeamAssignments" )
	for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
		print( "nPlayerID = "..nPlayerID )
		local nTeamID = PlayerResource:GetTeam( nPlayerID )
		if nTeamID ~= DOTA_TEAM_NOTEAM then
			print( "nTeamID = "..nTeamID )
			GameRules:SendCustomMessage( "#TeamAssignmentMessage", nPlayerID, -1 )
		end
	end
end