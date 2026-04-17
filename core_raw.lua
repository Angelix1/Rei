return function()
	-- coreVersion = 140
	local base = system.DocumentsDirectory
	-- Write all files
	local write = function(path, content)
	    local f = io.open(system.pathForFile(path, base), "w")
	    if f then f:write(content) f:close() end
	end


write("reinternal/core.lua", [=====[
	core = {}
	lfs = lfs or require("lfs")
	ModManager.version = "1.5.0"

	-- ============================================  actual code under
	function core.init()
	    EnableDebugLog = true -- false in release
	    logToFile("=============== [CORE:start] ===============")
	    modloc = {}

	    -- =============
	    ModManager.extendRoute("lib.ally.ally_command", "ally_command")
	    ModManager.extendRoute("lib.ally.ally_list", "ally")
	    ModManager.extendRoute("lib.base_npc.base_npc_list", "basenpc")
	    ModManager.extendRoute("lib.base_npc.buyer_list", "base_buyer")
	    ModManager.extendRoute("lib.base_npc.trader_list", "base_trader")
	    ModManager.extendRoute("lib.base_npc.workshop_list", "base_workshop")
	    ModManager.extendRoute("lib.base_npc.train_list", "base_train")
	    ModManager.extendRoute("lib.base_npc.product_list", "base_product")
	    ModManager.extendRoute("lib.base_npc.product_sell_list", "base_product_sell")
	    ModManager.extendRoute("lib.base_npc.product_craft_list", "base_product_craft")
	    ModManager.extendRoute("lib.base_npc.product_repair_list", "base_product_repair")
	    ModManager.extendRoute("lib.battle.obj_list.battle_map_list", "battle_map")
	    ModManager.extendRoute("lib.battle.obj_list.battle_map_decor_list", "battle_map_decor")
	    ModManager.extendRoute("lib.battle.obj_list.terrain_list", "battle_terrain")
	    ModManager.extendRoute("lib.battle.obj_list.terrain_decor_list", "battle_terrain_decor")
	    ModManager.extendRoute("lib.battle.obj_list.faction_list", "battle_faction")
	    ModManager.extendRoute("lib.battle.obj_list.weapon_human_list", "battle_weapon")

	    ModManager.extendRoute("lib.battle.obj_list.unit_ally_list", "battle_unit_ally")
	    ModManager.extendRoute("lib.battle.obj_list.unit_bandit_list", "battle_unit_enemy")
	    
	    ModManager.extendRoute("lib.battle.obj_list.enemy_animal_list", "battle_enemy_set")
	    ModManager.extendRoute("lib.battle.obj_list.effect_list", "battle_effect")
	    ModManager.extendRoute("lib.battle.obj_list.perk_list", "battle_perk")
	    ModManager.extendRoute("lib.chest.item_chest_list", "item_chest")
	    ModManager.extendRoute("lib.chest.chest_list", "chest")
	    ModManager.extendRoute("lib.config.hard_config", "config_hard")
	    ModManager.extendRoute("lib.cooking_list", "cooking")
	    ModManager.extendRoute("lib.disease.disease_list", "disease")
	    ModManager.extendRoute("lib.interface.image_list", "image")
	    ModManager.extendRoute("lib.interface.image_sheet_list", "image_sheet")
	    ModManager.extendRoute("lib.items.ammo", "item")
	    ModManager.extendRoute("lib.level.recipe_list", "recipe")
	    ModManager.extendRoute("lib.level.perk_list", "perk")
	    ModManager.extendRoute("lib.level.level_list", "level")
	    ModManager.extendRoute("lib.location.city_list", "location_city")
	    ModManager.extendRoute("lib.location.location_list", "location")
	    -- ModManager.extendRoute("lib.location.location_season_list", "location")
	    ModManager.extendRoute("lib.location.base_npc", "location_base_npc")
	    ModManager.extendRoute("lib.location.base_enemy", "location_base_enemy")
	    ModManager.extendRoute("lib.loot.item_loot_list", "loot_item")
	    ModManager.extendRoute("lib.loot.miniloc_loot_list", "loot_miniloc")
	    ModManager.extendRoute("lib.loot.location_loot_list", "loot_location")
	    ModManager.extendRoute("lib.miniloc.miniloc_list", "miniloc")
	    ModManager.extendRoute("lib.npc.npc_list", "npc")
	    ModManager.extendRoute("lib.quest.bar_quest_list", "quest_bar")
	    ModManager.extendRoute("lib.quest.quest_list", "quest")
	    ModManager.extendRoute("lib.random_event_list", "random_event")
	    ModManager.extendRoute("lib.weather.weather_list", "weather")
	    
	    
	    ModManager.catroute() -- create category routing
	    
	    ModManager.extendFuncRoute("lib.interface.image_master", "image_method")
	    ModManager.extendFuncRoute("lib.battle.unit_logic", "battle_unit_logic")    
	        
	    -- =====================================    
	    local loader = require("angel_mod.loader")
	    
	    local allMods = loader.loadMods()
	    
	    local general = {
	        fontSize = {
	            title = 46,
	            body = 40,
	            footer = 34
	        },
	        button = {
	            close = {
	                size = 80,
	                height = 60
	            }
	        },
	        edgeRound = 8,
	    }
	    
	    -- Core util here 
	    
	    if #allMods.preload > 0 then        
	        loader.executeMods(allMods.preload, true)
	    else    
	        logToFile("ℹ️ No preload mods to load")
	    end
	    
	    if #allMods.normal > 0 then
	        -- Checker configuration
	        local checkInterval = 1000 -- milliseconds 
	        local maxAttempts = 40
	        local attempts = 0
	        local checkerTimer = nil
	        local labels = "main.gameNetwork"
	        
	        -- Self-destructing checker function
	        local function checkNotifications()
	    	    if checkerTimer then
			        timer.cancel(checkerTimer)
			        checkerTimer = nil
			    end

	            attempts = attempts + 1
	            
	            -- Success condition
	            if type(main) == "table" and type(main.gameNetwork) == "table" then
	                logToFile("✅ " .. labels .. " ready - Executing normal mods")
	                loader.executeMods(allMods.normal, false)
	                
	                itemlist = main.itemlist.table
	                bweapon = main.battle.weapon.table
	                
	                -- Clean up
	                if checkerTimer then timer.cancel(checkerTimer) end
	                checkNotifications = nil  -- Remove function reference
	                return
	            end
	            
	            -- Fail condition
	            if attempts >= maxAttempts then
	                logToFile("❌ Failed to find " .. labels .. " after "..maxAttempts.." attempts")
	                
	                -- Clean up
	                if checkerTimer then timer.cancel(checkerTimer) end
	                checkNotifications = nil
	                return
	            end
	            
	            -- Continue checking
	            logToFile("🔍 Waiting for " .. labels .. " (Attempt "..attempts.."/"..maxAttempts..")")
	            checkerTimer = timer.performWithDelay(checkInterval, checkNotifications)
	        end
	        
	        -- Start the checker
	        logToFile("⏳ Delaying "..#allMods.normal.." normal mods until " .. labels .. " exist...")
	        checkNotifications()  -- Initial call
	    else    
	        logToFile("ℹ️ No normal mods to load")
	    end
	    
	    logToFile("[CORE] finished")
	end 



	return core
]=====])


write("reinternal/files.lua", [=====[
	local core = [[
		core = {}
		lfs = lfs or require("lfs")
		ModManager.version = "1.5.0"

		-- ============================================  actual code under
		function core.init()
		    EnableDebugLog = true -- false in release
		    logToFile("=============== [CORE:start] ===============")
		    modloc = {}

		    -- =============
		    ModManager.extendRoute("lib.ally.ally_command", "ally_command")
		    ModManager.extendRoute("lib.ally.ally_list", "ally")
		    ModManager.extendRoute("lib.base_npc.base_npc_list", "basenpc")
		    ModManager.extendRoute("lib.base_npc.buyer_list", "base_buyer")
		    ModManager.extendRoute("lib.base_npc.trader_list", "base_trader")
		    ModManager.extendRoute("lib.base_npc.workshop_list", "base_workshop")
		    ModManager.extendRoute("lib.base_npc.train_list", "base_train")
		    ModManager.extendRoute("lib.base_npc.product_list", "base_product")
		    ModManager.extendRoute("lib.base_npc.product_sell_list", "base_product_sell")
		    ModManager.extendRoute("lib.base_npc.product_craft_list", "base_product_craft")
		    ModManager.extendRoute("lib.base_npc.product_repair_list", "base_product_repair")
		    ModManager.extendRoute("lib.battle.obj_list.battle_map_list", "battle_map")
		    ModManager.extendRoute("lib.battle.obj_list.battle_map_decor_list", "battle_map_decor")
		    ModManager.extendRoute("lib.battle.obj_list.terrain_list", "battle_terrain")
		    ModManager.extendRoute("lib.battle.obj_list.terrain_decor_list", "battle_terrain_decor")
		    ModManager.extendRoute("lib.battle.obj_list.faction_list", "battle_faction")
		    ModManager.extendRoute("lib.battle.obj_list.weapon_human_list", "battle_weapon")

		    ModManager.extendRoute("lib.battle.obj_list.unit_ally_list", "battle_unit_ally")
		    ModManager.extendRoute("lib.battle.obj_list.unit_bandit_list", "battle_unit_enemy")
		    
		    ModManager.extendRoute("lib.battle.obj_list.enemy_animal_list", "battle_enemy_set")
		    ModManager.extendRoute("lib.battle.obj_list.effect_list", "battle_effect")
		    ModManager.extendRoute("lib.battle.obj_list.perk_list", "battle_perk")
		    ModManager.extendRoute("lib.chest.item_chest_list", "item_chest")
		    ModManager.extendRoute("lib.chest.chest_list", "chest")
		    ModManager.extendRoute("lib.config.hard_config", "config_hard")
		    ModManager.extendRoute("lib.cooking_list", "cooking")
		    ModManager.extendRoute("lib.disease.disease_list", "disease")
		    ModManager.extendRoute("lib.interface.image_list", "image")
		    ModManager.extendRoute("lib.interface.image_sheet_list", "image_sheet")
		    ModManager.extendRoute("lib.items.ammo", "item")
		    ModManager.extendRoute("lib.level.recipe_list", "recipe")
		    ModManager.extendRoute("lib.level.perk_list", "perk")
		    ModManager.extendRoute("lib.level.level_list", "level")
		    ModManager.extendRoute("lib.location.city_list", "location_city")
		    ModManager.extendRoute("lib.location.location_list", "location")
		    -- ModManager.extendRoute("lib.location.location_season_list", "location")
		    ModManager.extendRoute("lib.location.base_npc", "location_base_npc")
		    ModManager.extendRoute("lib.location.base_enemy", "location_base_enemy")
		    ModManager.extendRoute("lib.loot.item_loot_list", "loot_item")
		    ModManager.extendRoute("lib.loot.miniloc_loot_list", "loot_miniloc")
		    ModManager.extendRoute("lib.loot.location_loot_list", "loot_location")
		    ModManager.extendRoute("lib.miniloc.miniloc_list", "miniloc")
		    ModManager.extendRoute("lib.npc.npc_list", "npc")
		    ModManager.extendRoute("lib.quest.bar_quest_list", "quest_bar")
		    ModManager.extendRoute("lib.quest.quest_list", "quest")
		    ModManager.extendRoute("lib.random_event_list", "random_event")
		    ModManager.extendRoute("lib.weather.weather_list", "weather")
		    
		    
		    ModManager.catroute() -- create category routing
		    
		    ModManager.extendFuncRoute("lib.interface.image_master", "image_method")
		    ModManager.extendFuncRoute("lib.battle.unit_logic", "battle_unit_logic")    
		        
		    -- =====================================    
		    local loader = require("angel_mod.loader")
		    
		    local allMods = loader.loadMods()
		    
		    local general = {
		        fontSize = {
		            title = 46,
		            body = 40,
		            footer = 34
		        },
		        button = {
		            close = {
		                size = 80,
		                height = 60
		            }
		        },
		        edgeRound = 8,
		    }
		    
		    -- Core util here 
		    
		    if #allMods.preload > 0 then        
		        loader.executeMods(allMods.preload, true)
		    else    
		        logToFile("ℹ️ No preload mods to load")
		    end
		    
		    if #allMods.normal > 0 then
		        -- Checker configuration
		        local checkInterval = 1000 -- milliseconds 
		        local maxAttempts = 40
		        local attempts = 0
		        local checkerTimer = nil
		        local labels = "main.gameNetwork"
		        
		        -- Self-destructing checker function
		        local function checkNotifications()
		    	    if checkerTimer then
				        timer.cancel(checkerTimer)
				        checkerTimer = nil
				    end

		            attempts = attempts + 1
		            
		            -- Success condition
		            if type(main) == "table" and type(main.gameNetwork) == "table" then
		                logToFile("✅ " .. labels .. " ready - Executing normal mods")
		                loader.executeMods(allMods.normal, false)
		                
		                itemlist = main.itemlist.table
		                bweapon = main.battle.weapon.table
		                
		                -- Clean up
		                if checkerTimer then timer.cancel(checkerTimer) end
		                checkNotifications = nil  -- Remove function reference
		                return
		            end
		            
		            -- Fail condition
		            if attempts >= maxAttempts then
		                logToFile("❌ Failed to find " .. labels .. " after "..maxAttempts.." attempts")
		                
		                -- Clean up
		                if checkerTimer then timer.cancel(checkerTimer) end
		                checkNotifications = nil
		                return
		            end
		            
		            -- Continue checking
		            logToFile("🔍 Waiting for " .. labels .. " (Attempt "..attempts.."/"..maxAttempts..")")
		            checkerTimer = timer.performWithDelay(checkInterval, checkNotifications)
		        end
		        
		        -- Start the checker
		        logToFile("⏳ Delaying "..#allMods.normal.." normal mods until " .. labels .. " exist...")
		        checkNotifications()  -- Initial call
		    else    
		        logToFile("ℹ️ No normal mods to load")
		    end
		    
		    logToFile("[CORE] finished")
		end 



		return core
	]]

	local loaderLuaCode = [[
		-- main table
		local modLoader = {}

		-- Constants
		local MODS_DIR = "angel_mod/modlist"
		local MANIFEST_FILE = "manifest.lua"
		local LOG_FILE = "angel_mod/modlist/loader.log"
		local IGNORE_PREFIXES = {".", "_"}
		local IGNORE_FOLDERS = {"assets"}
		local loaderVersion = "1.4.0"

		-- Initialize logging
		local function loaderLog(message, wipe)
		    -- if not EnableDebugLog then return end
		    
		    local logPath = system.pathForFile(LOG_FILE, system.DocumentsDirectory)
		    
		    -- Wipe log if requested
		    if wipe then
		        local wipeFile = io.open(logPath, "w")
		        if wipeFile then
		            wipeFile:close()
		            return true  -- Return success status
		        end
		        return false
		    end
		    
		    -- Normal logging
		    local logFile = io.open(logPath, "a")
		    if not logFile then return false end
		    
		    local timestamp = os.date("[%Y-%m-%d %H:%M:%S]")
		    local success, err = pcall(function()
		        logFile:write(timestamp .. " " .. message .. "\n")
		    end)
		    
		    logFile:close()
		    return success, err
		end

		-- Helper function to check if a path should be ignored
		local function shouldIgnore(path)
		    local name = path:match("([^/\\]+)$") or path
		    
		    for _, prefix in ipairs(IGNORE_PREFIXES) do
		        if name:sub(1, #prefix) == prefix then
		            return true
		        end
		    end
		    
		    for _, folder in ipairs(IGNORE_FOLDERS) do
		        if name:lower() == folder:lower() then
		            return true
		        end
		    end
		    
		    return false
		end

		-- Load and validate a single mod
		local function loadMod(modPath)
		    local manifestPath = modPath .. "." .. MANIFEST_FILE:gsub(".lua$", "")
		    local success, manifest = pcall(require, manifestPath)
		    
		    if not success then
		        local a = "❌ Failed to load manifest from " .. modPath .. ": " .. tostring(manifest)
		        loaderLog(a)
		        error(a)
		        return nil
		    end
		    
		    if type(manifest) ~= "table" then
		        local _ = "❌ Manifest must return a table in " .. modPath
		        loaderLog(_)
		        error(_)
		        return nil
		    end

		    -- Validate required fields
		    local requiredFields = {
		        "modName", "modVersion", "modAuthor", 
		        "preLoad", "afterLoad", "coreVersion"
		    }
		    for _, field in ipairs(requiredFields) do
		        if manifest[field] == nil then
		            local _ = "❌ Missing required field '" .. field .. "' in " .. modPath
		            loaderLog(_)
		            error(_)
		            return nil
		        end
		    end
		    
		    -- Validate core version compatibility [ ADDED IN 1.1.0 ]
		    if not manifest.coreVersion then
		        local _ = "❌ Missing required field 'coreVersion' in " .. modPath
		        loaderLog(_)
		        error(_)
		        return nil
		    else
		        local versionCheck = ModManager.isVersionSufficient(manifest.coreVersion, ModManager.version)
		        if not versionCheck then
		            local _ = "❌ Mod requires ModManager version " .. manifest.coreVersion .. " or higher (current: " .. ModManager.version .. ", Please update to latest version or disable the mod) in " .. modPath
		            loaderLog(_)
		            error(_)
		            return nil
		        end
		    end
		    
		    -- validation for load categories
		    if not (manifest.preLoad or manifest.afterLoad) then
		        local err = "❌ Manifest must contain preLoad/afterLoad tables in "..modPath
		        loaderLog(err)
		        error(err)
		        return nil
		    end
		    
		    -- Verify files exist
		    local function verifyFiles(files)
		        for _, file in ipairs(files or {}) do
		            local filePath = modPath .. "." .. file:gsub("%.lua$", "")
		            local ok, err = pcall(require, filePath)
		            if not ok then
		                error("❌ Failed to load '" .. file .. "': " .. err)
		            end
		        end
		    end
		    
		    verifyFiles(manifest.preLoad)
		    verifyFiles(manifest.afterLoad)
		    
		    return manifest
		end

		-- Execute mod files
		local function executeMod(modPath, manifest)
		    for _, file in ipairs(manifest.modFiles) do
		        local filePath = modPath .. "." .. file:gsub(".lua$", "")
		        local success, modChunk = pcall(require, filePath)
		        
		        if success then            
		            if type(modChunk) == "function" then
		                local actionSuccess, actionResult = pcall(modChunk)
		                if not actionSuccess then
		                    loaderLog("❌ Error running action in " .. file .. ": " .. tostring(actionResult))
		                else
		                    loaderLog("✔ Executed " .. file)
		                end
		            else
		                loaderLog("ℹ️ " .. file .. " loaded but didn't return an action function")
		            end
		        else
		            loaderLog("❌ Failed to load " .. file .. ": " .. tostring(modChunk))
		        end
		            
		        -- ::continue::
		    end
		end

		-- Main loader function

		function modLoader.loadMods()
		    loaderLog(nil, true)  -- Clears the log file completely
		    loaderLog("=============================== [LOADER] Scanning for mods")
		    local basePath = system.pathForFile(MODS_DIR, system.DocumentsDirectory)
		    local mods = {
		        preload = {},
		        normal = {}
		    }
		    
		    -- Scan mod directory
		    for modFolder in lfs.dir(basePath) do
		        if modFolder ~= "." and modFolder ~= ".." then
		            local fullPath = basePath .. "/" .. modFolder
		            local attr = lfs.attributes(fullPath)
		            
		            if attr and attr.mode == "directory" and not shouldIgnore(modFolder) then
		                local modPath = MODS_DIR .. "/" .. modFolder
		                modPath = ModManager.replaceSlashes(modPath, ".")
		                local manifest = loadMod(modPath)
		                
		                if manifest then
		                    local modInfo = {
		                        path = modPath,
		                        manifest = manifest,
		                        name = manifest.modName,
		                        version = manifest.modVersion
		                    }
		                    
		                    -- Categorize by load phase
		                    if manifest.preLoad and #manifest.preLoad > 0 then
		                        table.insert(mods.preload, modInfo)
		                        loaderLog("✔ Found PRELOAD mod: "..manifest.modName)
		                    end
		                    
		                    if manifest.afterLoad and #manifest.afterLoad > 0 then
		                        table.insert(mods.normal, modInfo)  -- 'normal' now means afterLoad
		                        loaderLog("✔ Found AFTERLOAD mod: "..manifest.modName)
		                    end
		                end
		            end
		        end
		    end
		    
		    loaderLog(string.format("Scan complete: %d preload mods, %d normal mods found",
		        #mods.preload, #mods.normal))
		    
		    return mods
		end

		function modLoader.executeMods(modList, isPreloadPhase)
		    local count = 0
		    ModManager.loadedMods = ModManager.loadedMods or {}
		    
		    for _, mod in ipairs(modList or {}) do
		        local files = isPreloadPhase and mod.manifest.preLoad or mod.manifest.afterLoad
		        
		        for _, file in ipairs(files or {}) do
		            local filePath = mod.path.."."..file:gsub(".lua$", "")
		            loaderLog("⚡ Loading: "..file)
		            
		            local success, result = pcall(require, filePath)
		            if success then
		                if type(result) == "function" then
		                    local success, err = pcall(result)  -- Execute safely and capture errors
		                    if success then
		                        loaderLog("✅ Success: " .. file)
		                    else
		                        loaderLog("❌ Execution Failed: " .. file .. " | Error: " .. tostring(err))
		                    end
		                elseif result ~= nil then
		                    loaderLog("⚠️ Warning: " .. file .. " | Exported a " .. type(result) .. " (expected function).")
		                else
		                    loaderLog("❌ Failed: " .. file .. " | File does not export anything.")
		                end
		                count = count + 1
		                
		                -- Track mod without duplicates
		                if not tableContains(ModManager.loadedMods, mod.manifest) then
		                    table.insert(ModManager.loadedMods, mod.manifest)
		                end
		            else
		                loaderLog("❌ Failed: "..tostring(result))
		            end
		        end
		    end
		    
		    loaderLog(string.format("✅ Executed %d %s files", count, 
		        isPreloadPhase and "preLoad" or "afterLoad"))
		    return count > 0
		end

		return modLoader
	]]

	local featureFileCode = [[
		local version = "1.5.0"

		return {
		    {
		        id = "CONSOLE",
		        name = "Console",
		        func = function()
		            return nil
		        end
		    },
		    {
		        id = nil,
		        name = "Show loaded mods",
		        func = function(x)
		            --CM()
		            modlist_ui.Show(x)
		        end
		    },
		    {
		        id = nil,
		        name = "Add Helicarrier",
		        func = function()
		        	local data = {}
		        	data.id = "berserk"
		        	data.quantity = 1
		        	data.depreciation = 0
		        	
		        	if main.itemlist.get(main.itemlist, data.id) then
		            	main.inventory.add(data)
		            
		            	main.animation.addItem(main.animation, { "berserk", 1, 0 })
		            else
		            	main.interface.open(main.interface, {
		            		id = "message", title = "no", text = "no item" 
		            	})
		            end
		            return "added"
		        end
		    },
		    {
		        id = nil,
		        name = "Add debug tools",
		        func = function()
		            function create(name, qua, dep)
		                return { 
		                    id = name, 
		                    quantity = qua or 1, 
		                    depreciation = dep or 0 
		                }
		            end
		        	local data = {
		        	    create("agw_dto"),
		        	    create("agw_dto2")
		        	}
		        	
		        	local fx = ""
		        	
		        	for index = 1, #data, 1 do
		        	    if main.itemlist.get(main.itemlist, data[index].id) then
		                 	main.inventory.add(data[index])
		                 	
		                 	local f = { data[index].id, data[index].quantity, 0 }
		            
		                 	main.animation.addItem(main.animation, f)
		                else
		            	    fx = fx .. data[index].id .. "\n"
		                end
		            end
		            
		            if #fx > 0 then
		                main.interface.open(main.interface, {
		           	        id = "message", title = "Item Doesn't exist", text = fx
		                })
		            end
		            return "added"
		        end
		    },
		    {
		        id = nil,
		        name = "Add exp to char",
		        func = function()
		            closeModMenu()
		            main.interface:open({ 
		                id = "input_dialog", 
		                text = "Input exp amount to be given", 
		                title = "Exp", 
		                textConfirm = "Confirm", 
		                actionConfirm = function(self) 
		                    local text = self.text
		                    -- logToFile(text)
		                    if text and assert(type(tonumber(text))) == "number" then
		                        main.level.addExp(main.level, { expValue = tonumber(text) })
		                    elseif assert(type(tonumber(text))) ~= "number" then
		                        main.interface:open({
		                            id = "message",
		                            title = "Error",
		                            text = "Input not a number"
		                        })
		                    else
		                        main.interface:open({
		                            id = "message",
		                            title = "Error",
		                            text = "no input"
		                        })
		                    end
		                end 
		            })
		        end
		    },
		    {
		        id = nil,
		        name = "Give Caps",
		        func = function()
		            closeModMenu()
		            main.interface:open({ 
		                id = "input_dialog", 
		                text = "Input caps amount to be given", 
		                title = "Caps", 
		                textConfirm = "Confirm", 
		                actionConfirm = function(self) 
		                    local text = self.text
		                    -- logToFile(text)
		                    if text and assert(type(tonumber(text))) == "number" then
		                        main.profile.addCaps(main.profile, tonumber(text))
		                        main.animation.addItem(main.animation, { "caps", tonumber(text), 0 })
		                    elseif assert(type(tonumber(text))) ~= "number" then
		                        main.interface:open({
		                            id = "message",
		                            title = "Error",
		                            text = "Input not a number"
		                        })
		                    else
		                        main.interface:open({
		                            id = "message",
		                            title = "Error",
		                            text = "no input"
		                        })
		                    end
		                end 
		            })
		        end
		    },
		    {
		        id = nil,
		        name = "Currency Tool",
		        func = function()
		            closeModMenu()
		            main.interface:open({ 
		                id = "input_dialog", 
		                text = "Input type and amount to be given (add-iron_nut-10 | rem-iron_nut-10)", 
		                title = "type-CURRENCY-AMOUNT", 
		                textConfirm = "Confirm", 
		                actionConfirm = function(self) 
		                    local text = self.text
		                    --logToFile(text)
		                    if text then
		                        local sp = splitter(tostring(text), "-")
		                        if sp[1] and sp[2] and sp[3] then
		                            -- ModManager.showToast(dump(sp))
		                            if sp[1] == "add" then
		                                main.level:addCurrency(sp[2], tonumber(sp[3]))
		                            elseif sp[1] == "rem" then
		                                main.level:spendCurrency(sp[2], tonumber(sp[3]))
		                            else
		                                main.interface:open({
			                                id = "message",
			                                title = "Error",
			                                text = "malformed input; Type: unknown, expected 'rem' or 'add'"
			                            })
		                            end
		                        else
		                            main.interface:open({
		                                id = "message",
		                                title = "Error",
		                                text = "malformed input"
		                            })
		                        end
		                    else
		                        main.interface:open({
		                            id = "message",
		                            title = "Error",
		                            text = "no input"
		                        })
		                    end
		                end
		            })
		        end
		    },
		    {
		        id = nil,
		        name = "Item Tool",
		        func = function()
		            closeModMenu()
		            main.interface:open({ 
		                id = "input_dialog", 
		                text = "Input type and amount to be given (add-iron-10 | rem-scrap_metal)", 
		                title = "type-ITEMID-AMOUNT", 
		                textConfirm = "Confirm", 
		                actionConfirm = function(self) 
		                    local text = self.text
		                    --logToFile(text)
		                    if text then
		                        local sp = splitter(tostring(text), "-")
		                        if sp[1] and sp[2] then
		                            -- logToFile(dumpTableWithDepth(sp))
		                            if sp[1] == "add" and sp[3] then
			                            local datas = {
			                                id=sp[2],
			                                quantity= tonumber(sp[3]) or 1,
			                                depreciation = 0
			                            }
			                            main.inventory.add(datas)
			                         	main.animation.addItem(main.animation, { sp[2], (tonumber(sp[3]) or 1), 0 })
		                            elseif sp[1] == "rem" then
		                                rmItem(text)
		                            else
		                                main.interface:open({
			                                id = "message",
			                                title = "Error",
			                                text = "malformed input; Type: unknown, expected 'rem' or 'add' | Missing amount for addItem"
			                            })
		                            end
		                        else
		                            main.interface:open({
		                                id = "message",
		                                title = "Error",
		                                text = "malformed input"
		                            })
		                        end
		                    else
		                        main.interface:open({
		                            id = "message",
		                            title = "Error",
		                            text = "no input"
		                        })
		                    end
		                end
		            })
		        end
		    },
		    {
		        id = nil,
		        name = "Kill game",
		        func = function() os.exit() end
		    }
		}
	]]

	local menuFileCode = [[
		Data = {}
		
		local version = "1.5.0"

		local feature = require("angel_mod.feature")

		function splitter(str, split)
		    local results = {}
		    for part in str:gmatch(string.format("([^%s]+)", split)) do
		        table.insert(results, part)
		    end
		    return results
		end

		function CM()
		    closeModMenu()
		    if main.interface.group.mui.consoleGroup ~= nil then
		        main.interface.group.mui.consoleGroup:removeSelf()
		    end
		end

		function addItem(text)
		    CM()
		    if text == "all" then
		        main.itemlist.addAllToInventory(nil, 1)
		        return
		    end 
		    local sp = splitter(tostring(text), ".")
		    if sp[1] and sp[2] then
		        -- logToFile(dumpTableWithDepth(sp))
		        local datas = {
		            id=sp[1],
		            quantity= tonumber(sp[2]) or 1,
		            depreciation = 0
		        }
		        
		        main.inventory.add(datas)
		        
		     	main.animation.addItem(main.animation, { sp[1], (tonumber(sp[2]) or 1), 0 })
		     	
		    else
		        main.interface:open({
		            id = "message",
		            title = "Error",
		            text = "malformed input"
		        })
		    end
		end

		function rmItem(name)
		    CM()
		    tab = main.character.table.inventory
		    if name == "all" then
		        main.character.table.inventory = {}
		    else
		        table.remove(tab, table.js.findIndex(tab, function(v) return v[1] == name end))
		    
		        -- main.character.table.inventory = tab
		    end
		end

		local general = {
		    fontSize = {
		        title = 46,
		        body = 40,
		        footer = 34
		    },
		    button = {
		        close = {
		            size = 80,
		            height = 60
		        }
		    },
		    edgeRound = 8,
		}

		-- Function to show mod menu
		function Data.show(modMenu) -- mig.modMenuGroup
		    -- Check if mod menu is already shown, then close it
		    if modMenu.group then
		        Data.close(modMenu)
		        return
		    end
		    
		    main.interface:open({ 
		        id = "message", 
		        title = "Menu Info", 
		        text = "This exist to prevent other interface accidentally clicked, click ok or back button to close this"
		    })

		    -- Set modMenu isOpen flag to true
		    modMenu.isOpen = true

		    -- Create a group to hold all menu elements
		    modMenu.group = display.newGroup()

		    -- Get screen dimensions
		    local screenWidth = display.actualContentWidth
		    local screenHeight = display.actualContentHeight

		    -- Calculate menu box dimensions
		    local menuBoxWidth = screenWidth * 0.8
		    local menuBoxHeight = screenHeight * 0.8

		    -- Set sizes for header, footer, and buttons
		    local headerBoxHeight = 80
		    local footerBoxHeight = 80

		    -- Render mod menu UI
		    print("Mod menu shown!")

		    -- Create mod menu box
		    local menuBox = display.newRoundedRect(
		        modMenu.group, 
		        display.contentCenterX, 
		        display.contentCenterY, 
		        menuBoxWidth, 
		        menuBoxHeight,
		        general.edgeRound
		    )
		    menuBox:setFillColor(0.2, 0.2, 0.2)

		    -- Create header box
		    local headerBox = display.newRoundedRect(
		        modMenu.group, 
		        display.contentCenterX, 
		        menuBox.y - menuBoxHeight / 2 + headerBoxHeight / 2, 
		        menuBoxWidth, 
		        headerBoxHeight,
		        general.edgeRound
		    )
		    headerBox:setFillColor(0.3, 0.3, 0.3, 0.5)

		    -- Create Menu Title
		    local Title = display.newText(
		        modMenu.group, 
		        "Menu", 
		        menuBox.x, 
		        headerBox.y, 
		        native.systemFontBold, 
		        general.fontSize.title
		    )

		    -- Create close button
		    local closeButton = display.newText(
		        modMenu.group, 
		        "X", 
		        menuBox.x + menuBox.width / 2 - general.button.close.size * 1.5, 
		        headerBox.y, 
		        native.systemFontBold, 
		        general.button.close.size
		    )
		    closeButton:setFillColor(1, 0, 0)

		    -- Function to handle touch event on close button
		    local function closeButtonTouch(event)
		        if event.phase == "ended" then
		            Data.close(modMenu)
		            return true
		        end
		    end
		    closeButton:addEventListener("touch", closeButtonTouch)

		    -- Create body box for mod list
		    local bodyBoxHeight = menuBoxHeight - headerBoxHeight - footerBoxHeight
		    local bodyBox = display.newRect(modMenu.group, display.contentCenterX, menuBox.y, menuBoxWidth, bodyBoxHeight)
		    bodyBox:setFillColor(0.3, 0.3, 0.3)

		    -- print(bodyBox.x, menuBox.x )
		    -- Create scroll view for mod list
		    modMenu.group.scrollView = widget.newScrollView({
		        parent = modMenu.group,
		        x = bodyBox.x + 7,
		        y = bodyBox.y,
		        width = bodyBox.width - 50,
		        height = bodyBox.height,
		        horizontalScrollDisabled = true,
		        backgroundColor = {0.3, 0.3, 0.3},
		        listener = function() return true end -- Prevents touch propagation to underlying objects
		    })

		    -- Create mod menu buttons
		    local modButtonWidth = modMenu.group.scrollView.width - 20
		    local modButtonX = modMenu.group.scrollView.x + modMenu.group.scrollView.width / 2 -- Centering the buttons horizontally within the scroll view
		    local modButtonY = modMenu.group.scrollView.y - modMenu.group.scrollView.height / 2 + general.button.close.height / 2 -- Adjusted to remove padding

		    for i, mod in pairs(feature) do

		        if i == 1 then
		            modButtonY = general.button.close.height
		            modButtonX = modMenu.group.scrollView.x
		        end

		        local modButton = display.newRoundedRect(
		            modMenu.group, 
		            modButtonX, 
		            modButtonY, 
		            modButtonWidth - 200, 
		            general.button.close.height, 
		            general.edgeRound
		        )
		        modButton.x = bodyBox.width + 25
		        modButton:setFillColor(0.6, 0.6, 0.6)

		        -- Add mod index to button object for later reference
		        modButton.modIndex = i

		        -- Add touch event listener to mod menu button
		        if mod and mod.name and mod.func then
		            if mod.id == "CONSOLE" then
		                modButton:addEventListener("touch", function(event)
		                    if event.phase == "ended" then
		                        Data.openConsole(modMenu)
		                    end
		                    return true
		                end)
		            else
		                modButton:addEventListener("touch", function (ev) 
		                    modButtonTouch(ev, modMenu)
		                    return true
		                end)
		            end
		        end

		        if mod and mod.name and (mod.func and mod.name ~= "CONSOLE") then
		            -- Add label to mod menu button
		            local modLabel = display.newText(
		                modMenu.group, 
		                mod.name, 
		                modButtonX, 
		                modButtonY, 
		                native.systemFont, 
		                general.fontSize.body
		            )
		            modLabel:setFillColor(1, 1, 1)

		            -- Center mod button and label
		            modButton.x = modMenu.group.scrollView.x
		            modButton.anchorX = 0.5
		            modLabel.x = modMenu.group.scrollView.x
		            modLabel.anchorX = 0.5

		            -- Insert mod button into scroll view
		            modMenu.group.scrollView:insert(modButton)
		            modMenu.group.scrollView:insert(modLabel)

		            -- Update position for next button
		            modButtonY = modButtonY + general.button.close.height + 10 -- Adjusted to remove padding
		        end
		    end

		    -- Set menuBox flag to true
		    modMenu.group.isOpen = true
		end

		-- Function to close mod menu
		function Data.close(modMenu)
		    -- Check if mod menu is already closed
		    if modMenu and not modMenu.group then
		        return
		    end

		    -- Set modMenu isOpen flag to false
		    modMenu.isOpen = false

		    -- Show mod menu icon
		    if modMenu.micon then
		        modMenu.micon.isVisible = true
		    end

		    -- Remove any display objects related to the mod menu (e.g., menuBox, headerBox, bodyBox, footerBox)
		    display.remove(modMenu.group)
		    display.remove(modMenu.group.scrollView)
		    modMenu.group = nil

		    -- Reset any other mod menu-related variables or states as needed
		end


		-- Create mod menu buttons
		function modButtonTouch(event, modM)
		    -- Handle touch events for mod menu buttons
		    if event.phase == "ended" then
		   
		        -- Animate the color change
		        if event.target ~= nil and assert(type(event.target.setFillColor)) == "function" then
		            transition.to(event.target, {time = 200, transition = easing.outQuad, onComplete = function()
		                if event.target.setFillColor ~= nil then
		                    event.target:setFillColor(0.6, 0.6, 0.6) -- Return to grey
		                end 
		            end})
		    
		            -- Animate the color change
		            transition.to(event.target, {time = 200, delay = 200, transition = easing.inQuad, onComplete = function()
		                if event.target.setFillColor ~= nil then
		                    event.target:setFillColor(0.5, 1, 0.5) -- Return to grey
		                end 
		            end})
		        end
		        
		        local modIndex = event.target.modIndex

		        if feature[modIndex].func ~= nil then
		            feature[modIndex].func(modM)
		        else
		            native.alert("Error", feature[modIndex].name .." has no function", {"otay"})
		        end
		        -- You can add logic here to apply the selected mod
		    end
		    return true
		end

		-- Define a global display group for the console UI
		function Data.openConsole(modMenu)

		    -- Render console UI
		    print("Opening console UI")
		    -- Clear the console group
		    if modMenu.consoleGroup then
		        modMenu.consoleGroup:removeSelf()
		    end

		    local generalFontSize = 24

		    modMenu.consoleGroup = display.newGroup()

		    -- Create resizable box for console
		    local consoleWidth = display.contentWidth * 0.75
		    local consoleHeight = display.contentHeight * 0.75

		    -- Create console background
		    local consoleBackground = display.newRect(
		        modMenu.consoleGroup, 
		        display.contentCenterX, 
		        display.contentCenterY, 
		        consoleWidth, 
		        consoleHeight
		    )
		    consoleBackground:setFillColor(0.2, 0.2, 0.2, 0.8)
		    consoleBackground.strokeWidth = 1
		    consoleBackground:setStrokeColor(1, 1, 1)

		    -- Create header
		    local header = display.newRect(
		        modMenu.consoleGroup, 
		        display.contentCenterX, 
		        consoleBackground.y - consoleHeight / 2 + 20, 
		        consoleWidth, 
		        40
		    )
		    header:setFillColor(0.4, 0.4, 0.4)

		    local headerText = display.newText(
		        modMenu.consoleGroup, 
		        "Console", 
		        header.x, 
		        header.y, native.systemFontBold, 
		        general.fontSize.title
		    )

		    -- Create close button
		    local closeButton = display.newText(
		        modMenu.consoleGroup, 
		        "X", 
		        consoleBackground.x + consoleWidth / 2 - 20, 
		        header.y, 
		        native.systemFontBold, 
		        general.button.close.size
		    )
		    closeButton:setFillColor(1, 0, 0)
		    closeButton:addEventListener("tap", function()
		        Data.closeConsole(modMenu)
		    end)

		    -- Create text input
		    local inputField = native.newTextBox(
		        display.contentCenterX, 
		        consoleBackground.y, 
		        consoleWidth * 0.75, 
		        consoleHeight * 0.75
		    )
		    inputField.size = 18
		    inputField.text = "main"
		    inputField.isEditable = true
		    
		    modMenu.consoleGroup:insert(inputField)

		    -- Create eval button
		    local evalButton = display.newText(
		        modMenu.consoleGroup, 
		        "Eval", 
		        display.contentCenterX, 
		        consoleBackground.y + consoleHeight / 2 - 50, 
		        native.systemFontBold, 
		        general.fontSize.title
		    )
		    evalButton:setFillColor(1, 1, 1)
		    
		    local function sendEvalButtonTouch(event)
		        local userInput = inputField.text
		    
		        -- Try evaluating as an expression first
		        local chunk, err = loadstring("return " .. tostring(userInput))
		    
		        if not chunk then
		            -- If it fails, try it as a statement
		            chunk, err = loadstring(tostring(userInput))
		    
		            if not chunk then
		                inputField.text = "Error during compilation: \n\n" .. tostring(dump(err, 5))
		                return
		            end
		        end
		    
		        local success, result = pcall(chunk)
		    
		        if success then
		            -- Ensure `false` and `nil` are displayed correctly
		            if result == nil then
		                inputField.text = "nil"
		            elseif result == false then
		                inputField.text = "false"
		            else
		                inputField.text = tostring(dump(result, 5))
		            end
		        else
		            inputField.text = "Error during execution:\n\n" .. tostring(dump(result, 5))
		        end
		    end
		    evalButton:addEventListener("tap", sendEvalButtonTouch)

		    -- Add the console group to the stage
		    -- display.getCurrentStage():insert(modMenu.consoleGroup)
		end

		function closeModMenu()
		    Data.close(main.interface.group.mui)
		end

		function Data.closeConsole(modMenu)
		    -- Remove the console group from the stage
		    if modMenu.consoleGroup then
		        modMenu.consoleGroup:removeSelf()
		        print("Console closed!")
		    end
		end


		--=== thingy
		modlist_ui = {}
		scrollView = nil
		scrollGroup = nil
		MODLOADED = { 
		    { name = "Test", author = "test", version = "1.0.0" },
		    -- { name = "Test Mod", author = "bob", version = "1.0.0", description = "test description" }
		}

		-- Helper: truncate text with ellipsis
	    local function truncateText(text, font, fontSize, maxWidth)
	        local temp = display.newText({
	            text = text,
	            font = font,
	            fontSize = fontSize
	        })
	        temp.isVisible = false
	    
	        while temp.width > maxWidth and #text > 0 do
	            text = text:sub(1, -2)
	            temp.text = text .. "..."
	        end
	    
	        local result = temp.text
	        temp:removeSelf()
	        return result
	    end

		-- Show the loaded mod list
		function modlist_ui.Show(parentGroup)
		    if scrollGroup then return end -- Already shown

		    parentGroup.scrollGroup = display.newGroup()
		    
		    scrollGroup = parentGroup.scrollGroup

		    scrollView = widget.newScrollView({
		        width = display.contentWidth * 0.9,
		        height = display.contentHeight * 0.8,
		        scrollWidth = 0,
		        scrollHeight = 0,
		        backgroundColor = {0.1, 0.1, 0.1, 0.95},
		        horizontalScrollDisabled = true,
		        topPadding = 20,
		        bottomPadding = 20,
		        x = display.contentCenterX + 100
		    })

		    scrollView.x = display.contentCenterX
		    scrollView.y = display.contentCenterY
		    scrollGroup:insert(scrollView)

		    -- Close button (top-right corner)
		    local closeButton = display.newText({
		        text = "X",
		        x = scrollView.x + scrollView.width * 0.5 - 10,
		        y = scrollView.y - scrollView.height * 0.5 + 10,
		        font = native.systemFontBold,
		        fontSize = general.button.close.size
		    })
		    closeButton:setFillColor(1, 0.2, 0.2)
		    closeButton.anchorX, closeButton.anchorY = 1, 0
		    closeButton:addEventListener("tap", function()
		        modlist_ui.Hide()
		    end)
		    scrollGroup:insert(closeButton)
		    
		    local MDL = ModManager.loadedMods or {}
		    
		    -- Display mod list
		    if type(MDL) == "table" then
		        local padding = 20
		        local yPos = padding + 40
		    
		        for _, manifest in pairs(MDL) do
		            local bgHeight = 120
		    
		            local bg = display.newRoundedRect(0, yPos, scrollView.width * 0.95, bgHeight, 12)
		            bg.anchorX = 0
		            bg:setFillColor(0.2, 0.2, 0.2, 0.9)
		            scrollView:insert(bg)
		            
		            local info = {
		                description = manifest.modDescription,
		                name = manifest.modName,
		                version = manifest.modVersion,
		                author = manifest.modAuthor
		            }
		    
		            -- Mod Title
		            local title = display.newText({
		                text = info.name or "unknown mod",
		                x = bg.x + 10,
		                y = bg.y - 30,
		                width = bg.width - 20,
		                font = native.systemFontBold,
		                fontSize = 30,
		                align = "left"
		            })
		            title.anchorX = 0
		            title:setFillColor(1, 1, 1)
		            scrollView:insert(title)
		    
		            -- Author
		            local author = info.author or "Unknown"
		            local subText = display.newText({
		                text = "by " .. author,
		                x = bg.x + 10,
		                y = bg.y,
		                font = native.systemFont,
		                fontSize = 24,
		                align = "left"
		            })
		            subText.anchorX = 0
		            subText:setFillColor(0.8, 0.8, 0.8)
		            scrollView:insert(subText)
		    
		            -- Version (anchored right)
		            local versionText = display.newText({
		                text = info.version or "?",
		                x = bg.x + bg.width * 0.95,
		                y = title.y,
		                font = native.systemFont,
		                fontSize = 20,
		                align = "right"
		            })
		            versionText.anchorX = 1
		            versionText:setFillColor(0.7, 0.7, 0.7)
		            scrollView:insert(versionText)
		    
		            -- Description with truncation
		            local rawDesc = info.description or "No description"
		            local descWidth = bg.width - 20
		            local descText = truncateText(rawDesc, native.systemFont, 22, descWidth)
		    
		            local description = display.newText({
		                text = descText,
		                x = bg.x + 10,
		                y = bg.y + 30,
		                width = descWidth,
		                font = native.systemFont,
		                fontSize = 24,
		                align = "left"
		            })
		            description.anchorX = 0
		            description:setFillColor(0.8, 0.8, 0.8)
		            scrollView:insert(description)
		    
		            yPos = yPos + bg.height + padding
		        end
		    end
		    
		    scrollGroup:toFront()
		end

		-- Hide the mod list
		function modlist_ui.Hide()
		    if scrollGroup then
		        scrollGroup:removeSelf()
		        scrollGroup = nil
		        scrollView = nil
		    end
		end


		return Data
	]]

	local example_mod_afterload = [[
		--- Afterload Phase Script
		-- Use this for:
		-- - Modifying existing game objects
		-- - Patching vanilla functions
		-- - Runtime adjustments

		-- Must Return A Function 
		return function() 
		    -- 1. Direct value replacement (Make sure you know the path exist or it'll throw an error)
		    main.game.items.sword.damage = 200  -- Buff vanilla sword
		    
		    -- 2. Function patching (Only for existing one)
		    local oldAttack = main.game.player.attack
		    function main.game.player.attack(target)
		        -- Add 10% crit chance
		        if math.random() < 0.1 then
		            return oldAttack(target) * 2
		        end
		        return oldAttack(target)
		    end

		end
	]]

	local example_mod_preload = [[
		--- Preload Phase Script
		-- Use this for:
		-- - Registering new items/entities
		-- - Adding content via ModManager APIs
		-- - Override important function 
		-- Avoid:
		-- - Modifying existing game objects
		-- - Accessing uninitialized game systems

		-- NOTE:
		-- If your items uses custom assets use this template relative path
		--          modded_assets/YourModFolderName/*
		--  E.g    modded_assets/EPX/weapon/plasma_gun
		-- The Assets must end with .png as extension because the game expect PNG
		-- Do Not Include extension in the asset path


		local modName = "Epic Weapons Expansion"

		-- Required to return a function
		return function()

		    -- 1. Register new weapons
		    ModManager.register("item", {
		        {
		            id = "plasma_rifle",
		            name = "PLASMA-9000",
		            damage = {1000, 5000},
		            imageFile = "modded_assets/EPX/weapons/plasma"
		        },
		        -- More items...
		    }, modName)
		    
		    -- 2. Register function overrides (if needed) [THIS IS EXAMPLE, WILL NOT WORK]
		    ModManager.regFuncOverride("render_weapons", {
		        -- Will replace lib.render.weaponDraw()
		        weaponDraw = function(weapon, x, y)
		            -- Custom drawing logic
		        end
		    }, modName)

		end
	]]

	local example_mod_manifest = [[
		--- Mod Manifest Definition
		-- @field modName (Required) Display name for the mod
		-- @field modVersion (Required) Version string (semantic versioning recommended)
		-- @field modAuthor (Required) Author/developer credit
		-- @field preLoad Table of files to load BEFORE game initialization
		-- @field afterLoad Table of files to load AFTER game initialization
		-- @field dependencies Informal list of required mods (e.g., {"corelib@1.2"})

		return {
		    -- REQUIRED FIELDS
		    modName = "Epic Weapons Expansion",
		    modVersion = "2.3.1",
		    modAuthor = "BorisTheModder",
		    coreVersion = "1.0.0", -- Minimum CORE version to use this mod (useful for required internal functions to works)
		    
		    -- LOAD PHASE CONTROL
		    preLoad = {
		        -- These files can safely:
		        -- Register new items/entities
		        -- Add to ModManager tables
		        -- NOT modify existing game objects
		        -- Lua uses . as delimiter between folders
		        "preload.item_init.lua"
		    },
		    
		    afterLoad = {
		        -- These files can:
		        -- Modify existing game objects
		        -- Patch vanilla functions
		        -- Adjust balance values
		        "afterload.damage.lua"
		    },
		    
		    -- METADATA (Optional)
		    description = "Adds 15 new weapons and rebalances combat",
		    dependencies = {} -- Not yet Implemented
		}
	]]

	local readme = [[
		# **Day R Survival Modding Guide**  
		*(For Modders - Place mods in `angel_mod/modlist/`)*  

		## **📁 Folder Structure**  
		```markdown
		angel_mod/
		├── modlist/                          # All mods go here
		│    ├── assets/                     # *Ignored* by loader
		│    └── cool_mod/                  # Example mod folder  
		│          └── manifest.lua     
		├── loader.log                         # Debug logs  
		└── (other files)  
		```

		---

		## **📜 Mod Folder Rules**  
		1. **Required Files**  
		   - `manifest.lua` → *Must* define `modName`, `modVersion`, `modAuthor`, and load phases.  
		   - At least one of:  
		     - files listed in `manifest.preLoad`
		     - files listed in `manifest.afterLoad`  

		2. **Ignored Content**  
		   - Mod folders starting with `.` or `_` (e.g., `.temp/`, `_test/`)  
		   - `assets/` folders → *Useful for shared assets between mods*  

		3. **Loader Behavior**  
		   - **Logs**: Check `angel_mod/loader.log` for load errors.  
		   - **Crashes**: Remove problematic mods and check logs.  

		---

		## **🛠️ Example Mod**  
		- **Refer to `.example_mod` for example mod** *(Only example, not usable for usage)*

		---

		## **❗ Important Notes**  
		- **No Hot-Reloading**: Restart the game to apply mods.  
		- **Load Order**: Alphabetical by folder name.  
		- **Conflicts**: Last-loaded mod wins (check logs for warnings) or duplicates will overwritten.  
		- **Debugging**:  
		  - Errors appear in `loader.log`.  
		  - Use `ModManager.showToast()` for in-game alerts.
		  - E.g `ModManager.showToast("Testing")`

		---

		## **🚫 Restricted Actions**  
		- **Do NOT**:  
		  - Modify files outside `modlist/`. *(You might broke the core or other critical V2L functions)*
		  - Overwrite core game assets *(If you don't know what you doing, DO NOT Overwrite anything)*

		---

		**Need Help?**  
		Check `loader.log` or ask in the modding community!  

		---
	]]

	return {
		core = core,
		loader = loaderLuaCode,
		feature = featureFileCode,
		menu = menuFileCode,
		example_mod_afterload = example_mod_afterload,
		example_mod_preload = example_mod_preload,
		example_mod_manifest = example_mod_manifest,
		readme = readme
	}
]=====])


write("reinternal/lib.lua", [=====[
	-- ================================== Function Hijacks

	-- Updated in v150
	function require(path)
	    -- Splash screen hook (unchanged)
	    if path == "lib.loading._loading_master" then
	        local old = oldRequire(path)
	        local origStart = old.start
	        old.origStart = origStart
	        old.start = function(m)
	            timer.performWithDelay(2000, function()
	                timer.performWithDelay(500, showSplash)
	                old.origStart(m)
	            end)
	        end
	        return old
	    end
	    
	    -- Cache lookups
	    local funcCategory = ModManager.funcroute[path]
	    local funcOverride = funcCategory and ModManager.funcOverride[funcCategory]
	    local dataCategory = ModManager.routing[path]
	    local dataOverride = dataCategory and ModManager.mods[dataCategory]
	    
	    -- Early exit for non-modded paths
	    if not funcCategory and not dataCategory then
	        return oldRequire(path)
	    end

	    local success, original = pcall(oldRequire, path)
	    if not success then
	        logToFile("[ModManager] REQUIRE FAILED: "..path.." | Error: "..tostring(original))
	        return nil
	    end
	    
	    if type(original) == "table" then
	        local modified = table.copy({ original })[1]  -- Always copy first
	        
	        if funcOverride then
	            -- PHASE 1: Replace Whole Table
	            if funcOverride.isReplaceTable then
	                modified = funcOverride.replacement
	                logToFile("[ModManager] FULL TABLE REPLACEMENT: ".. path)        
	            -- PHASE 2: Function/Value overrides        
	            elseif funcOverride.isIndexedTable then
	                    -- check item key
	                local targetCond = funcOverride.targetKey
	                
	                for _, item in ipairs(modified) do -- loop original 
	                    local fix = item[targetCond]
	                    if fix and funcOverride[fix] then  -- Check if ID exists and has overrides
	                        for path, override in pairs(funcOverride[fix]) do -- loop mod entry
	                            local target = item
	                            local keys = {}
	                            
	                            -- Split path (e.g., "stat.damage" → {"stat", "damage"})
	                            for part in path:gmatch("[^.]+") do
	                                table.insert(keys, part)
	                            end
	            
	                            -- Navigate to target (skip if invalid path)
	                            for i = 1, #keys-1 do
	                                if type(target) ~= "table" or not target[keys[i]] then 
	                                    break 
	                                end
	                                target = target[keys[i]]
	                            end
	                            
	                            target[keys[#keys]] = override
	                            logToFile(string.format("[ModManager] Override [Index] %s.%s = %s", item.id, path, override))
	                        end
	                    end
	                end
	            elseif funcOverride.append then
	                if funcOverride.data then
	                    modified = table.js.safeMerge(modified, funcOverride.data)
	                end
	            else 
	            -- Normal Mode (Flat/dot-notation overrides)
	                for path, override in pairs(funcOverride) do
	                    local target = modified
	                    local keys = {}
	                    
	                    for part in path:gmatch("[^.]+") do
	                        table.insert(keys, part)
	                    end
	                    
	                    for i = 1, #keys-1 do
	                        if not target[keys[i]] then break end
	                        target = target[keys[i]]
	                    end
	                    
	                    if target[keys[#keys]] then
	                        target[keys[#keys]] = override
	                        logToFile(string.format("[ModManager] Override [FlatKey] %s.%s", path, path))
	                    end
	                end
	            end
	        end
	        -- PHASE 3: Data merges
	        if dataOverride then
	            modified = table.copy(modified, ModManager.deepCopyWithResolution({}, dataOverride))
	        end

	        return modified
	    else
	        -- PHASE 2: Global hijacks
	        if funcOverride then
	            for funcPath, override in pairs(funcOverride) do
	                if override.nonExport and override.func then
	                    local target = _G
	                    local parts = {}
	                    
	                    for part in funcPath:gmatch("[^.]+") do
	                        table.insert(parts, part)
	                    end
	                    
	                    for i = 1, #parts-1 do
	                        if not target[parts[i]] then break end
	                        target = target[parts[i]]
	                    end
	                    
	                    if target and target[parts[#parts]] then
	                        target[parts[#parts]] = override.func
	                        logToFile("[ModManager] Hijacked: "..funcPath)
	                    end
	                end
	            end
	        end
	        return original
	    end
	end

	display.newImage = function(...)
	    -- Handle non-string paths safely
	    local args = {...}
	    local firstArg = args[1]
	    if type(firstArg) ~= "string" then
	        return originalNewImage(...)  -- Fall back to original behavior
	    end

	    local originalPath = firstArg
	    local isModded = includes(originalPath, "modded_assets/")
	    local finalPath = originalPath

	    -- Process modded paths
	    if isModded then
	        -- Extract mod path (e.g., "modded_assets/assets/image.png")
	        local modRelativePath = originalPath:match("modded_assets/(.+)")
	        if modRelativePath then
	            finalPath = system.pathForFile("angel_mod/modlist/"..modRelativePath, system.DocumentsDirectory)
	            
	            -- LFS file check
	            local fileAttr = lfs.attributes(finalPath)
	            if not fileAttr or fileAttr.mode ~= "file" then
	                logToFile("[Image Load] MOD MISSING: "..finalPath)
	                return originalNewImage(...)  -- Fallback to original asset
	            end
	        end
	    end

	    -- Debug logging
	    if EnableDebugLog then
	    	logToFile(string.format("[Image Load] %s: %s", isModded and "MOD" or "ORIGINAL", isModded and finalPath or originalPath ))
	    end

	    -- Protected load
	    local success, image = pcall(originalNewImage, finalPath, select(2, ...))
	    if success then
	        return image
	    else
	        logToFile("[Image Load] FAILED: "..finalPath.." | "..tostring(image))
	        return originalNewImage(...)  -- Ultimate fallback
	    end
	end
	-- ==================================================================== setup files

	local filesData = sreq("reinternal.files")

	if filesData then
		-- List of Folder that needs to be created
		local folders = {
		    "angel_mod",
		    "angel_mod/modlist",
		    "angel_mod/modlist/assets",
		    "angel_mod/modlist/.example_mod",
		    "angel_mod/modlist/.example_mod/afterload",
		    "angel_mod/modlist/.example_mod/preload",
		}

		-- list of files that needs to be created
		local files = {
		    {
		        path = "reinternal/core.lua",
		        content = filesData.core
		    },
		    { 
		        path = "angel_mod/feature.lua", 
		        content = filesData.feature
		    },
		    { 
		        path = "angel_mod/loader.lua", 
		        content = filesData.loader 
		    },
		    { 
		        path = "angel_mod/menu.lua", 
		        content = filesData.menu
		    },
		    {
		        path = "angel_mod/modlist/.example_mod/afterload/damage.lua",
		        content = filesData.example_mod_afterload
		    },
		    {
		        path = "angel_mod/modlist/.example_mod/preload/item.lua",
		        content = filesData.example_mod_preload
		    },
		    {
		        path = "angel_mod/modlist/.example_mod/manifest.lua",
		        content = filesData.example_mod_manifest
		    },
		    {
		        path = "angel_mod/modlist/readme.md",
		        content = filesData.readme
		    }
		}

		setupModDirectories(folders, files)

	end

	-- ==================================================================== Things
	ModManager.clearLog("debug_log.txt")
	modMenu = require("angel_mod.menu")



	-- ==================================================================== INIT
	local core = sreq("reinternal.core")
	if core and core.init then
		core.init()
	else
		logToFile("Core Not Found")
	end
]=====])


write("reinternal/manager.lua", [=====[
	-- Initialize core tables
	ModManager.mods = ModManager.mods or {}
	ModManager.routing = ModManager.routing or {}
	ModManager.category = ModManager.category or {}
	ModManager.funcOverride = ModManager.funcOverride or {}
	ModManager.funcroute = ModManager.funcroute or {}
	ModManager.funccat = ModManager.funccat or {}
	ModManager.loadedMods = ModManager.loadedMods or {}


	ModManager.debug = {
	    list = function()
	        local output = {}
	        for category, items in pairs(ModManager.mods) do
	            table.insert(output, string.format("%s (%d items)", category, #items))
	        end
	        ModManager.showToast("Mod Categories:\n"..table.concat(output, "\n"))
	    end,
	    find = function(id)
	        for category, items in pairs(ModManager.mods) do
	            for _, item in ipairs(items) do
	                if item.id == id then
	                    ModManager.showToast(string.format(
	                        "'%s' found in %s\nMod: %s",
	                        id, category, item.modName
	                    ))
	                    return
	                end
	            end
	        end
	        ModManager.showToast("ID '"..id.."' not found")
	    end
	}

	ModManager.resolutionPatterns = {
	    "^strings%.",
	    "^modloc%.",
	    -- Add more patterns here as needed
	}

	-- =========== General Functions
	function ModManager.safeRequire(path)  
	    local ok, result = pcall(require, path)  -- Wrap vanilla require
	    if not ok then
	        logToFile("[Mod Manager] Optional module not found: " .. path)
	        return nil
	    end
	    return result
	end

	function ModManager.clearLog(targetfile)
	    local logPath = system.pathForFile(targetfile, system.DocumentsDirectory)
	    local wipeFile = io.open(logPath, "w")
	    if wipeFile then
	        wipeFile:close()
	        return true  -- Return success status
	    end
	    return false
	end

	-- added for extending the resolution table
	function ModManager.addResolutionPatterns(...)
	    for _, pattern in ipairs({...}) do
	        table.insert(ModManager.resolutionPatterns, pattern)
	    end
	end

	-- Updated in v1.1.2
	function ModManager.deepCopyWithResolution(t, s)
	    for k, v in pairs(s) do
	        if type(v) == "string" then
	            local shouldResolve = false
	            -- Check against all configured patterns
	            for _, pattern in ipairs(ModManager.resolutionPatterns) do
	                if v:match(pattern) then
	                    shouldResolve = true
	                    break
	                end
	            end
	            
	            if shouldResolve then
	                t[k] = ModManager.resolveGlobalPath(v) or v
	            else
	                t[k] = v
	            end
	        elseif type(v) == "table" then 
	            t[k] = ModManager.deepCopyWithResolution({}, v)
	        else
	            t[k] = v
	        end
	    end
	    return t
	end

	function ModManager.resolveGlobalPath(path)
	    local func, err = loadstring("return " .. path)
	    if not func then
	        logToFile("[ModManager] Load error: " .. tostring(err))
	        return path
	    end

	    local ok, result = pcall(func)
	    if ok then
	        return result
	    else
	        logToFile("[ModManager] Resolve failed: " .. path .. " | " .. tostring(result))
	        return path
	    end
	end

	function ModManager.safeEval(path, noReturn)
	    local f, loadErr 
	    if noReturn then
	        f, loadErr = loadstring(path)
	    else
	        f, loadErr = loadstring("return " .. path)
	    end
	    if not f then
	        logToFile("[ModManager] safeEval load error: " .. tostring(loadErr))
	        return false, loadErr
	    end

	    local ok, result = pcall(f)
	    if not ok then
	        logToFile("[ModManager] safeEval runtime error: " .. tostring(result))
	        return false, result
	    end

	    return true, result
	end

	function ModManager.replaceSlashes(input_str, replacement)
	    replacement = replacement or ""  -- Default: remove slashes
	    return string.gsub(input_str, "/", replacement)
	end

	function ModManager.showToast(message, title, opt)
	    if not message then
	    	return ModManager.showToast("ModManager.showToast(message[string], title[string], opt[table])")
	    end
	    if type(opt) ~= "table" then
	        opt = { "OK" }
	    end
	    
	    title = title or "Info"
	    
	    -- Attempt native toast first
	    if native.showAlert then
	        native.showAlert(title, message, opt)
	    else
	    	main.interface:open({
				id = "message",
				title = "Toast",
				text = message
			})
	    end
	    
	    logToFile("[TOAST] "..message)
	end

	function ModManager.exportModList()
	    local path = system.pathForFile("modlist.txt", system.DocumentsDirectory)
	    local file = io.open(path, "w")
	    
	    if not file then
	        ModManager.showToast("Failed to save modlist!")
	        return
	    end
	    
	    file:write("=== ACTIVE MODS ===\n")
	    for _, items in pairs(ModManager.loadedMods) do
	        file:write(string.format("\n[%s]\n", items.name))
	        
	    end
	    
	    file:close()
	    ModManager.showToast("Modlist saved to documents")
	    logToFile("[EXPORT] Modlist saved to "..path)
	end

	-- Added: 1.1.0
	function ModManager.isVersionSufficient(requiredVersion, currentVersion)
	    -- Return true if no required version is specified
	    if not requiredVersion or requiredVersion == "" then return true end
	    
	    -- Return false if current version doesn't exist
	    if not currentVersion or currentVersion == "" then return false end

	    -- Split version strings into numeric components
	    local function splitVersion(version)
	        local parts = {}
	        for part in string.gmatch(version, "%d+") do
	            table.insert(parts, tonumber(part))
	        end
	        return parts
	    end

	    local reqParts = splitVersion(requiredVersion)
	    local curParts = splitVersion(currentVersion)

	    -- Compare each component
	    for i = 1, math.max(#reqParts, #curParts) do
	        local req = reqParts[i] or 0
	        local cur = curParts[i] or 0

	        if req > cur then
	            return false  -- Current version is insufficient
	        elseif req < cur then
	            return true   -- Current version exceeds requirement
	        end
	        -- If equal, skip
	    end

	    return true  -- Versions are exactly equal
	end


	-- =========== Modder-friendly API
	function ModManager.regFuncOverride(category, funcData, label)
	    label = label or "unnamed"
	    
	    if type(funcData) ~= "table" then
	        logToFile("[ModManager] ERROR: funcData must be a table ("..label..")")
	        return
	    end
	    
	    -- Check if category exists
	    if not ModManager.funccat[category] then
	        local available = {}
	        for _, cat in pairs(ModManager.funccat) do
	            table.insert(available, cat)
	        end
	        table.sort(available)
	        
	        logToFile(string.format(
	            "[ModManager] ERROR (%s): Invalid category '%s'\n"..
	            "Available: %s\n"..
	            "Did you mean? Or call ModManager.extendFuncRoute('your.path', '%s')",
	            label, category, table.concat(available, ", "), category
	        ))
	        return
	    end

	    -- Initialize mods table for this category if needed
	    if not ModManager.funcOverride[category] then
	        ModManager.funcOverride[category] = {}
	    end
	    
	    for funcName, newFunc in pairs(funcData) do
	        ModManager.funcOverride[category][funcName] = newFunc
	        logToFile(string.format(
	            "[ModManager] Registered function '%s' in category '%s' (%s)",
	            funcName, category, label
	        ))
	    end
	end

	function ModManager.register(category, data, label) -- "drink", {} , "MOD Kewl"
	    -- Input validation
	    label = label or "unnamed_mod"

	    if type(data) ~= "table" then
	        logToFile("[ModManager] ERROR: Data must be a table ("..label..")")
	        return
	    end
	    
	    -- Check if category exists
	    if not ModManager.category[category] then
	        local available = {}
	        for _, cat in pairs(ModManager.category) do
	            table.insert(available, cat)
	        end
	        table.sort(available)
	        
	        logToFile(string.format(
	            "[ModManager] ERROR (%s): Invalid category '%s'\n"..
	            "Available: %s\n"..
	            "Did you mean? Or call ModManager.extendRoute('your.path', '%s')",
	            label, category, table.concat(available, ", "), category
	        ))
	        return
	    end

	    -- Initialize mods table for this category if needed
	    if not ModManager.mods[category] then
	        ModManager.mods[category] = {}
	    end
	    
	    -- Filter and insert valid data
	    local filteredData = {}
	    for _, item in pairs(data) do
	        if item and (item.id or item.name) then
	            table.insert(filteredData, item)
	        end
	    end
	  
	    for _, cleanData in pairs(filteredData) do
		    -- Conflict check
	    	local key = cleanData.id or cleanData.name
	        if key then
	            if conflictTracker[key] then
	                -- ModManager.showToast(string.format("CONFLICT: %s overwrites %s", label, key))
	                logToFile(string.format(
	                    "[CONFLICT] %s -> %s (previously by %s)",
	                    label, key, conflictTracker[key]
	                ))
	            end
	            conflictTracker[key] = label
	        end
	        table.insert(ModManager.mods[category], cleanData)
	    end
	    
	    logToFile(string.format(
	        "[ModManager] Registered %d/%s entry to '%s' (Mod Name: %s)",
	        #filteredData,
	        tostring(#data) or "n",
	        category,
	        label
	    ))
	end


	-- =========== Extend the Routing
	function ModManager.extendFuncRoute(path, category)
	    if type(path) == "string" and type(category) == "string" then
	        ModManager.funcroute[path] = category
	        ModManager.funccat[category] = path
	        logToFile("[ModManager] Mapped '"..path.."' → function category '"..category.."' | '".. category .."' → to path'"..path.."'")
	    else
	        logToFile("[ModManager.extendFuncRoute] WARNING: Invalid route extension - both arguments must be strings")
	    end
	end

	function ModManager.extendRoute(path, category) -- "lib.items.drink", "drink"
	    if type(path) == "string" and type(category) == "string" then
	        -- Add to path→category mapping
	        ModManager.routing[path] = category
	        
	        -- Check if category exist
	        if not ModManager.category then
	        	ModManager.category = {}
	        end

	        -- Add to category→paths mapping
	        ModManager.category[category] = path
	        
	        logToFile("[ModManager] Added route: "..path.." → "..category)
	        logToFile("[ModManager] Added category: "..category.." → "..path)
	    else
	        logToFile("[ModManager.extendRoute] WARNING: Invalid route extension - both arguments must be strings")
	    end
	end

	-- init mods routing for category
	function ModManager.catroute()
	    if ModManager.category then
	        ModManager.category = {}
	    end
	    
	    for path, category in pairs(ModManager.routing) do
	        ModManager.category[category] = path
	    end

	    logToFile("[ModManager] categories has been setup")
	end
]=====])


write("reinternal/utility.lua", [=====[
	function setupModDirectories(folders, files)
		local basePath = system.pathForFile("", system.DocumentsDirectory)

		if not folders and not files then
			logToFile("[setupModDirectories] ❌ inputs[folders|files] nil")
			return
		end
		
		if type(folders) ~= "table" and type(files) ~= "table" then
			logToFile("[setupModDirectories] ❌ inputs[folders|files] is not a table")
			return
		end
		
		-- Create folders
		for _, folder in ipairs(folders) do
			local fullPath = basePath .. "/" .. folder
			if not lfs.attributes(fullPath) then
				local success, err = lfs.mkdir(fullPath)
				if not success then
					logToFile("[setupModDirectories] ❌ Failed to create '"..folder.."': "..tostring(err))
					return false
				end
				logToFile("[setupModDirectories] ✔ Created directory: "..folder)
			end
		end
		
		-- Create files (only if they don't exist)
		for _, file in ipairs(files) do
			local fullPath = basePath .. "/" .. file.path
			if not io.open(fullPath, "r") then
				local f = io.open(fullPath, "w")
				if f then
					f:write(file.content)
					f:close()
					logToFile("[setupModDirectories] ✔ Created file: "..file.path)
				else
					logToFile("[setupModDirectories] ❌ Failed to create file: "..file.path)
					return false
				end
			end
		end
		
		return true
	end

	function includes(s, substring)
		return string.find(s, substring, 1, true) ~= nil
	end

	function endswith(s, suffix)
		return string.sub(s, -#suffix) == suffix
	end

	function startswith(s, prefix)
		return string.sub(s, 1, #prefix) == prefix
	end

	function tableContains(tbl, item)
		for _, value in pairs(tbl) do
			if value == item then
				return true
			end
		end
		return false
	end

	function getModPath(originalPath)
		-- Check if path contains "modded_assets/"
		if not includes(originalPath, "modded_assets/") then
			return nil  -- Not a mod path
		end

		-- Extract everything after "modded_assets/"
		local modRelativePath = originalPath:match("modded_assets/(.+)")
		
		-- Rebuild full path in DocumentsDirectory
		return system.pathForFile("angel_mod/modlist/" .. modRelativePath, system.DocumentsDirectory)
	end

	function dump(tbl, maxDepth)
		if type(tbl) ~= "table" then
			return tbl
		end
		maxDepth = maxDepth or 5

		local function dumpTable(tbl, depth, maxDepth)
			if depth > maxDepth then
				return "default table: " .. tostring(tbl)
			end

			local nl = "\n"
			local eqm = "\""

			local result = "{" .. nl
			local indent = string.rep("  ", depth)


			for k, v in pairs(tbl) do
				result = result .. indent .. "[" .. tostring(k) .. "] = "

				if type(v) == "table" then
					result = result .. dumpTable(v, depth + 1, maxDepth)
				elseif type(v) == "string" then
					result = result .. eqm .. tostring(v) .. eqm
				else
					result = result .. tostring(v)
				end

				result = result .. "," .. nl
			end

			result = result .. string.rep("  ", depth - 1) .. "}"
			return result
		end

		return dumpTable(tbl, 1, maxDepth)
	end


	function wtf(filename, message)
		local path = system.pathForFile(filename .. ".txt" or "unnamed.txt", system.DocumentsDirectory)
		local file = io.open(path, "a") -- Append mode
		if file then
			if type(message) == "table" then				
				file:write("\n\n" .. tostring(dump(message)) .. "\n\n")
				io.close(file)
			else
				file:write(tostring(message) .. " \n\n")
				io.close(file)
			end
		end
	end
		
			
	--- Helper: Checks if a table is an array (sequential numeric indices starting at 1)
	--- @param t table The table to check
	--- @return boolean True if the table is an array
	function isArray(t)
	    if type(t) ~= "table" then return false end
	    local count = 0
	    for k, _ in pairs(t) do
	        if type(k) ~= "number" or k < 1 or math.floor(k) ~= k then
	            return false
	        end
	        count = count + 1
	    end
	    -- Check if indices are sequential (no gaps)
	    for i = 1, count do
	        if t[i] == nil then
	            return false
	        end
	    end
	    return true
	end

	--- Helper: Appends array items from source to destination
	--- @param dest table Destination array
	--- @param src table Source array
	function appendArray(dest, src)
	    for _, item in ipairs(src) do
	        table.insert(dest, item)
	    end
	end

	--- Deep-merges tables, recursively. Last value wins on conflicts.
	--- Arrays are concatenated instead of having indices overwritten.
	--- @param ... Tables to merge (rightmost has highest priority for non-arrays)
	--- @return Merged table
	function table.js.merge(...)
	    local result = {}
	    for i = 1, select("#", ...) do
	        local tbl = select(i, ...)
	        if type(tbl) == "table" and tbl ~= nil then
	            for k, v in pairs(tbl) do
	                if type(v) == "table" and type(result[k]) == "table" then
	                    -- Check if both are arrays
	                    if isArray(v) and isArray(result[k]) then
	                        -- Create a new array combining both
	                        local merged = {}
	                        appendArray(merged, result[k])
	                        appendArray(merged, v)
	                        result[k] = merged
	                    else
	                        result[k] = table.js.merge(result[k], v)  -- Recurse
	                    end
	                else
	                    result[k] = v  -- Overwrite (or set new key)
	                end
	            end
	        end
	    end
	    return result
	end

	--- Deep-merges tables but errors on type clashes.
	--- Arrays are concatenated instead of having indices overwritten.
	--- @param ... Tables to merge
	--- @return Merged table
	--- @error If types conflict (e.g., string vs table) for non-array values
	function table.js.safeMerge(...)
	    local result = {}
	    for i = 1, select("#", ...) do
	        local tbl = select(i, ...)
	        if type(tbl) == "table" and tbl ~= nil then
	            for k, v in pairs(tbl) do
	                if type(v) == "table" and type(result[k]) == "table" then
	                    -- Check if both are arrays
	                    if isArray(v) and isArray(result[k]) then
	                        -- Create a new array combining both
	                        local merged = {}
	                        appendArray(merged, result[k])
	                        appendArray(merged, v)
	                        result[k] = merged
	                    else
	                        result[k] = table.js.safeMerge(result[k], v)  -- Recurse
	                    end
	                elseif result[k] ~= nil and type(v) ~= type(result[k]) then
	                    error(string.format(
					        "Type clash at key '%s': expected %s, got %s",
					        k, type(result[k]), type(v)
					    ))
					    return {}
	                else
	                    result[k] = v
	                end
	            end
	        end
	    end
	    return result
	end

	--- Safely fetches nested keys using a dot-delimited path.
	--- @param tbl table The root table to traverse.
	--- @param path string The path (e.g., "item.player.data").
	--- @return any|nil The value or nil if not found.
	function table.safeGet(tbl, path)
	    if type(tbl) ~= "table" then return nil end
	    local keys = {}
	    for key in path:gmatch("([^.]+)") do  -- Split by dots
	        table.insert(keys, key)
	    end
	    for _, key in ipairs(keys) do
	        if type(tbl) ~= "table" then return nil end
	        tbl = tbl[key]
	    end
	    return tbl
	end

	-- ====== table utilities 
	function table.js.values(tbl)
	    if type(tbl) ~= "table" then return tbl end
	    local values = {}
	    for _, v in pairs(tbl) do table.insert(values, v) end
	    return values
	end

	function table.js.keys(tbl)
	    if type(tbl) ~= "table" then return tbl end
	    local keys = {}
	    for k in pairs(tbl) do table.insert(keys, k) end
	    return keys
	end

	function table.js.find(tbl, fn)
	    for k, v in pairs(tbl) do
	        if fn(v, k) then return v end
	    end
	end

	function table.js.filter(tbl, fn)
	    local result = {}
	    for k, v in pairs(tbl) do
	        if fn(v, k) then result[k] = v end
	    end
	    return result
	end

	function table.js.map(tbl, fn)
	    local result = {}
	    for k, v in pairs(tbl) do
	        result[k] = fn(v, k)
	    end
	    return result
	end

	function table.js.findIndex(tbl, predicate, usePairs)
	    local iterator = usePairs and pairs or ipairs
	    for k, v in iterator(tbl) do
	        if predicate(v, k, tbl) then
	            return usePairs and k or tonumber(k)
	        end
	    end
	    return nil
	end	
		
	function ensurePath(path)
	    local current = ""
	    for part in path:gmatch("[^/]+") do
	        current = current .. "/" .. part
	        lfs.mkdir(current)
	    end
	end

	function tableContains(tbl, item)
	    if type(tbl) ~= "table" then
	        return false
	    end
	    for _, v in pairs(tbl) do
	        if v == item then
	            return true
	        end
	    end
	    return false
	end
]=====])


-- write("reinternal/.lua", [=====[]=====])
-- write("reinternal/.lua", [=====[]=====])


write("coreVersion.lua", [=====[
	return {
		version = 150
	}
]=====])


end