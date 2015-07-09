
function on_attacked( keys )
	local target = keys.target

	if not target:HasModifier("modifier_peasant_survival_instincts") then
		target:ForceKill(true)
	end
end