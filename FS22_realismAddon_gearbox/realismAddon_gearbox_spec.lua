-- by modelleicher ( Farming Agency )



realismAddon_gearbox_spec = {}

function realismAddon_gearbox_spec.prerequisitesPresent(specializations)
    return true
end

function realismAddon_gearbox_spec.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", realismAddon_gearbox_spec);
	SpecializationUtil.registerEventListener(vehicleType, "onUpdate", realismAddon_gearbox_spec);

	
	--SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", realismAddon_gearbox_inputs);
end

function realismAddon_gearbox_spec.registerFunctions(vehicleType)
	SpecializationUtil.registerFunction(vehicleType, "processSecondGroupSetInputs", realismAddon_gearbox_spec.processSecondGroupSetInputs)
end

-- helper function to get XML value on key and fallback key (basically instead of getConfigurationValue but without Schemas)
function getXMLValueFallback(xml, key, defaultKey, path, type, propertyCheck, defaultValue)
	if propertyCheck then
		if hasXMLProperty(xml, key..path) or hasXMLProperty(xml, defaultKey..path) then 
			return true
		else
			return false
		end
	else
		local value = getXMLString(xml, key..path) 
        local value2 = getXMLString(xml, defaultKey..path)         
        if type == "bool" then
            value = getXMLBool(xml, key..path) 
            value2 = getXMLBool(xml, defaultKey..path)            
        elseif type == "float" then
            value = getXMLFloat(xml, key..path) 
            value2 = getXMLFloat(xml, defaultKey..path)             
        end

		if value == nil then
            value = value2
			if value == nil then
				return defaultValue
			end
		end
		return value
	end
	
end


function realismAddon_gearbox_spec:onLoad(savegame)

    self.spec_realismAddon_gearbox = {}
    local spec = self.spec_realismAddon_gearbox

	-- get config key and default key 
	local key, _ = ConfigurationUtil.getXMLConfigurationKey(self.xmlFile,  self.configurations.motor, "vehicle.motorized.motorConfigurations.motorConfiguration", "vehicle.motorized", "motor")
	local defaultKey = "vehicle.motorized.motorConfigurations.motorConfiguration(0)"

    -- groups second set key 
    local groupsSecondSetKey = ".transmission.realismAddon_gearbox.groupsSecondSet"

    -- since we don't use the predefined xml Schemas we need to use the handle of the XML file
    local xml = self.xmlFile.handle    

	-- check for and load groups second set 
	local hasGroupsSecondSet = getXMLValueFallback(xml, key, defaultKey, groupsSecondSetKey, nil, true)
	if hasGroupsSecondSet then
			
		spec.groupsSecondSet = {}
		spec.groupsSecondSet.groups = {}
		spec.groupsSecondSet.currentGroup = 1
		spec.groupsSecondSet.wantedGroup = nil
        spec.groupsSecondSet.lastGroupSecond = nil
        spec.groupsSecondSet.lastGroupFirst = nil

        -- powershift allows for shifting without clutch - preselect means that the range is preselected and then automatically shifts once the clutch is pressed 
		spec.groupsSecondSet.powerShift = getXMLValueFallback(xml, key, defaultKey, groupsSecondSetKey.."#powerShift", "bool", nil, false)
		spec.groupsSecondSet.preselect = getXMLValueFallback(xml, key, defaultKey, groupsSecondSetKey.."#preselect", "bool", nil, false)

        -- load all individual group ratios
		local i = 0
		while true do
			local ratio = getXMLValueFallback(xml, key, defaultKey, groupsSecondSetKey..".group("..tostring(i)..")#ratio", "float")
			local name = getXMLValueFallback(xml, key, defaultKey, groupsSecondSetKey..".group("..tostring(i)..")#name", nil, nil, i+1)
			local isDefault = getXMLValueFallback(xml, key, defaultKey, groupsSecondSetKey..".group("..tostring(i)..")#isDefault", "bool", nil, false)
						
			if ratio ~= nil then
                if isDefault then
                    spec.groupsSecondSet.currentGroup = i+1
                end              

				spec.groupsSecondSet.groups[i+1] = {ratio = ratio, name = name, isDefault = isDefault}
			else
				break
			end
		
			i = i+1
		end 

        -- backup gearGroup names since we add the 2 names of the default and second group set together later 
        spec.groupsSecondSet.gearGroupNamesBackup = {}
    	local motor = self.spec_motorized.motor    
        for x = 1, #motor.gearGroups do
            spec.groupsSecondSet.gearGroupNamesBackup[x] = motor.gearGroups[x].name
        end

        -- in case we don't have any group ratios set everything to nil 
        if #spec.groupsSecondSet.groups == 0 then
            spec.groupsSecondSet = nil
        end
	
	end   


end

-- process the inputs of the secondGroupSet Input Call
function realismAddon_gearbox_spec:processSecondGroupSetInputs(wantedGroup, noEventSend)
	setGroupSecondEvent.sendEvent(self, wantedGroup, noEventSend)
	
	
	local motor = self.spec_motorized.motor
	local spec = self.spec_realismAddon_gearbox

    -- if the groupSet is powerShift or if the clutch is fully depressed allow shifting right away
	if spec.groupsSecondSet.powerShift or motor:getManualClutchPedal() > 0.8 then 
        spec.groupsSecondSet.currentGroup = wantedGroup  
    elseif spec.groupsSecondSet.preselect then -- if the groupSet is preselect type then don't shift right away but put wanted group into wantedGroup variable
		spec.groupsSecondSet.wantedGroup = wantedGroup
	end

end



-- UPDATE
function realismAddon_gearbox_spec:onUpdate(dt)

	if self:getIsActive() then
	
		local spec = self.spec_realismAddon_gearbox	
        local motor = self.spec_motorized.motor       
	
		-- check if transmission is manual 
		if realismAddon_gearbox_overrides.checkIsManual(motor) then
	
			if spec.groupsSecondSet ~= nil then	
                
                -- reset the name as soon as currentGroup changes
				if motor.gearGroups ~= nil and motor.activeGearGroupIndex > 0 and #motor.gearGroups > 0 then
					if spec.groupsSecondSet.lastGroupSecond ~= spec.groupsSecondSet.currentGroup or spec.groupsSecondSet.lastGroupFirst ~= motor.activeGearGroupIndex then
						local name = tostring(spec.groupsSecondSet.gearGroupNamesBackup[motor.activeGearGroupIndex]).." "..tostring(spec.groupsSecondSet.groups[spec.groupsSecondSet.currentGroup].name)
						local gearGroup = motor.gearGroups[motor.activeGearGroupIndex]
						if gearGroup ~= nil then
							gearGroup.name = name  
						end
						spec.groupsSecondSet.lastGroupSecond = spec.groupsSecondSet.currentGroup 
						spec.groupsSecondSet.lastGroupFirst = motor.activeGearGroupIndex
					end
				end
				
                -- if we have a wantedGroup set differently to currentGroup and we are in preselect mode we check for clutch opening and set the group if the clutch is open
                -- this needs no further synchronization because the clutch and wantedGroup are already synchronized
				if spec.groupsSecondSet.wantedGroup ~= nil and spec.groupsSecondSet.wantedGroup ~= spec.groupsSecondSet.currentGroup and spec.groupsSecondSet.preselect then               
                    if motor:getManualClutchPedal() > 0.8 then
						spec.groupsSecondSet.currentGroup = spec.groupsSecondSet.wantedGroup
                        spec.groupsSecondSet.wantedGroup = nil                                  
					end	
				end
			
			end
		end
			
	end
	
end



setGroupSecondEvent = {}
local setGroupSecondEvent_mt = Class(setGroupSecondEvent, Event)

InitEventClass(setGroupSecondEvent, "setGroupSecondEvent")

function setGroupSecondEvent.emptyNew()
	return Event.new(setGroupSecondEvent_mt)
end

function setGroupSecondEvent.new(object, wantedState)
	local self = setGroupSecondEvent.emptyNew()
	self.object = object
	self.wantedState = wantedState

	return self
end

function setGroupSecondEvent:readStream(streamId, connection)
	self.object = NetworkUtil.readNodeObject(streamId)
	self.wantedState = streamReadUIntN(streamId, 5)

	self:run(connection)
end

function setGroupSecondEvent:writeStream(streamId, connection)
	NetworkUtil.writeNodeObject(streamId, self.object)
	streamWriteUIntN(streamId, self.wantedState, 5)
end

function setGroupSecondEvent:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, self.object)
	end

	if self.object ~= nil and self.object:getIsSynchronized() then
		self.object:processSecondGroupSetInputs(self.wantedState, true);
	end
end

function setGroupSecondEvent.sendEvent(object, wantedState, noEventSend)
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(setGroupSecondEvent.new(object, wantedState), nil, nil, object)			
		else
			g_client:getServerConnection():sendEvent(setGroupSecondEvent.new(object, wantedState))
		end
	end
end