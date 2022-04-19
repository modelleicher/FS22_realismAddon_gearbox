-- by modelleicher ( Farming Agency )
-- register realismAddon_gearbox specializations and insert to vehicles 


g_specializationManager:addSpecialization("realismAddon_gearbox_inputs", "realismAddon_gearbox_inputs", g_currentModDirectory.."realismAddon_gearbox_inputs.lua")

realismAddon_gearbox_register = {}

realismAddon_gearbox_register.done = false

function realismAddon_gearbox_register:register(name)

	if not realismAddon_gearbox_register.done then
    
		for _, vehicle in pairs(g_vehicleTypeManager:getTypes()) do
			
			local motorized = false;
			local realismAddon_gearbox_inputs = false;
			
			for _, spec in pairs(vehicle.specializationNames) do
			
				if spec == "motorized" then -- check for motorized, only insert into motorized
					motorized = true;
				end
				if spec == "realismAddon_gearbox_inputs" then -- don't insert if already inserted
					realismAddon_gearbox_inputs = true;
				end
				
			end    
			if motorized and not realismAddon_gearbox_inputs then
				g_vehicleTypeManager:addSpecialization(vehicle.name, "FS22_realismAddon_gearbox.realismAddon_gearbox_inputs")
			end
		end
		
		realismAddon_gearbox_register.done = true
	end
end

TypeManager.finalizeTypes = Utils.prependedFunction(TypeManager.finalizeTypes, realismAddon_gearbox_register.register)