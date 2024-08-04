local HttpService = game:GetService('HttpService')
local API_Dump_Url = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/Mini-API-Dump.json"
local API_Dump = httpget(API_Dump_Url)


local function API(object, property)
    local apiProperty = tostring(property):gsub("_xml$", "")
    local isHidden = tostring(property):lower() ~= apiProperty:lower()

    local apiData = HttpService:JSONDecode(API_Dump)
    for _, class in pairs(apiData.Classes) do
        if tostring(object.ClassName) == class.Name then
            for _, member in pairs(class.Members) do
                if member.MemberType == "Property" and member.Name:lower() == apiProperty:lower() then
                    isHidden = isHidden or (member.Tags and (
                        table.find(member.Tags, "Hidden") or 
                        table.find(member.Tags, "NotScriptable")
                    )) or false
                    return member.Name, isHidden
                end
            end
        end
    end
    return apiProperty, true
end




sethiddenproperty = function(object, property, value)
    local apiProperty, _ = API(object, property)
    
    local methods = {
        function() object[apiProperty] = value; return true end,
        function() object:SetAttribute(apiProperty, value); return true end,
        function()
            local mt = getrawmetatable(object)
            if mt and mt.__newindex then
                mt.__newindex(object, apiProperty, value)
                return true
            end
        end
    }
    
    for _, method in ipairs(methods) do
        local success = pcall(method)
        if success then return true end
    end
    
    return false
end

 
gethiddenproperty = function(object, property)
    local apiProperty, isHidden = API(object, property)
    
    local methods = {
        function() return object[apiProperty] end,
        function() return object:GetAttribute(apiProperty) end,
        function() 
            local mt = getrawmetatable(object)
            if mt and mt.__index then
                return mt.__index(object, apiProperty)
            end
        end
    }
    
    for _, method in ipairs(methods) do
        local success, result = pcall(method)
        if success and result ~= nil then
            return result, isHidden
        end
    end
    
    return nil, isHidden
end
