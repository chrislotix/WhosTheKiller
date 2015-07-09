-- Triggers upon killing the killer
-- sets the attacker as the game winner
function end_game( keys )
	local attacker = keys.attacker
	local team = attacker:GetTeamNumber()
	GameRules:SetGameWinner(team)
	statcollection.sendStats({})
end

function end_game_portal( keys )
	local target = keys.target
	local player_id = target:GetPlayerID()

	if player_id then
		local player = PlayerResource:GetPlayer(player_id)

		if player.killer and not target:HasModifier("modifier_end_game") then
			GameRules:SetGameWinner(target:GetTeamNumber())
			statcollection.sendStats({})
		end
	end	
end