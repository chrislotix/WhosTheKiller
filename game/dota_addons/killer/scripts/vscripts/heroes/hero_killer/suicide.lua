--[[Kills the caster]]
function suicide( keys )
	local caster = keys.caster

	caster:ForceKill(true)
end