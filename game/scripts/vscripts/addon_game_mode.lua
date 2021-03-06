MAXIMUM_ATTACK_SPEED	= 700
MINIMUM_ATTACK_SPEED	= 20

ROUND_END_DELAY = 3

DOTA_LIFESTEAL_SOURCE_NONE = 0
DOTA_LIFESTEAL_SOURCE_ATTACK = 1
DOTA_LIFESTEAL_SOURCE_ABILITY = 2


CUSTOM_GAME_STATE_HERO_SELECTION = 1
CUSTOM_GAME_STATE_SKILL_SELECTION = 2
CUSTOM_GAME_STATE_GAME = 3
_G["HERO_SELECTION_TIME"] = 80
_G["SKILL_SELECTION_TIME"] = 80

MAP_CENTER = Vector(332, -1545)

if CRaidKings == nil then
	CRaidKings = class({})
end

require( "libraries/Timers" )
require( "libraries/notifications" )
require("libraries/utility")
require("libraries/animations")
require("hero_selection")
require("skill_selection")
require("statsmanager")

-- require("relics/relic")
-- require("relics/relicpool")

-- Precache resources
function Precache( context )
end

-- Actually make the game mode when we activate
function Activate()
	GameRules.gameMode = CRaidKings()
	GameRules.gameMode:InitGameMode()
	require("projectilemanager")
	-- require('statsmanager')
end


function CRaidKings:InitGameMode()
	print ("Raid Kings Loaded")
	GameRules.CRaidKings = CRaidKings()
	
	-- Load unit KVs into main kv
	GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
	MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_units_custom.txt"))
	
	GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
	MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/npc_items_custom.txt"))
	
	GameRules.HeroList = LoadKeyValues("scripts/npc/activelist.txt")
	print(GetMapName())
	local heroList = {}
	for k,v in pairs(GameRules.HeroList) do
		table.insert(heroList, k)
	end
	CustomNetTables:SetTableValue("hero_selection", "herolist", heroList)
	
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_STRENGTH_DAMAGE, 0 ) 
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_STRENGTH_HP, 0 ) 
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_STRENGTH_HP_REGEN_PERCENT, 0 )
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_STRENGTH_STATUS_RESISTANCE_PERCENT, 0 )
	
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_AGILITY_DAMAGE, 0 )
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_AGILITY_ARMOR, 0 )
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_AGILITY_ATTACK_SPEED, 0	 )
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_AGILITY_MOVE_SPEED_PERCENT, 0 )
	
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_INTELLIGENCE_DAMAGE , 0 ) 
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_INTELLIGENCE_MANA  , 0 ) 
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_INTELLIGENCE_MANA_REGEN_PERCENT, 0 )
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_INTELLIGENCE_SPELL_AMP_PERCENT, 0 )
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_INTELLIGENCE_MAGIC_RESISTANCE_PERCENT, 0 ) 
	
	
	GameRules:SetHeroSelectionTime( 0.0 )
	GameRules:SetPreGameTime( 0.0 )
	GameRules:SetShowcaseTime( 0 )
	GameRules:SetStrategyTime( 0 )
	GameRules:SetCustomGameSetupAutoLaunchDelay(0) -- fix valve bullshit
	
	local mapInfo = LoadKeyValues( "addoninfo.txt" )[GetMapName()]
	
	GameRules.BasePlayers = mapInfo.MaxPlayers
	GameRules._maxLives =  mapInfo.Lives
	GameRules.gameDifficulty =  mapInfo.Difficulty
	
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetUseUniversalShopMode( true )


	GameRules:SetTreeRegrowTime( 30.0 )
	GameRules:SetCreepMinimapIconScale( 1.5 )
	GameRules:SetRuneMinimapIconScale( 1 )
	GameRules:SetGoldTickTime( 600.0 )
	GameRules:SetGoldPerTick( 0 )
	
	GameRules:GetGameModeEntity():SetRemoveIllusionsOnDeath( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	GameRules:GetGameModeEntity():SetBuybackEnabled( false )
	GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_wisp")
	xpTable = {
		0,-- 1
		100,-- 2
		200,-- 3
		300,-- 4
		400,-- 5
		500,-- 6
		600,-- 7
		700,-- 8
		800,-- 9
		900,-- 10
		1000,-- 11
		1200,-- 12
		1400,-- 13
		1600,-- 14
		1800,-- 15
		2000,-- 16
		2250,-- 17
		2500,-- 18
		2750,-- 19
		3000,-- 20
		3500,-- 21
		4000,-- 22
		4500,-- 23
		5000,-- 24
		5500, -- 25
		6000, -- 26
		7000, -- 27
		8000, -- 28
		9000, -- 29
		10000, -- 30
		12500, -- 31
		15000, -- 32
		17500, -- 33
		20000, -- 34
		25000, -- 35
		30000, -- 36
		35000, --37
		40000, --38
		50000, --39
		60000, --40
		70000, --41
		80000, --42
		100000, --43
		150000, --44
		200000, --45
		300000, --46
		400000, --47
		500000, --48
		600000, --49
		700000, --50
		800000, --51
		900000, --52
		1000000, --53
		1200000, --54
		1400000, --55
		1600000, --56
		1800000, --57
		2000000, --58
		2200000, --59
		2400000, --60
		2600000, --61
		2800000, --62
		3000000, --63
		3500000, --64
		4000000, --65
		4500000, --66
		5000000, --67
		5500000, --68
		6000000, --69
		7000000, --70
		8000000, --71
		9000000, --72
		10000000, --73
		12500000, --74
		15000000, --75
		17500000, --76
		20000000, --77
		25000000, --78
		30000000, --79
		40000000, --80
	}

	GameRules:GetGameModeEntity():SetUseCustomHeroLevels( true )
    GameRules:GetGameModeEntity():SetCustomHeroMaxLevel( 80 )
    GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel( xpTable )
	
	GameRules:GetGameModeEntity():SetMaximumAttackSpeed(MAXIMUM_ATTACK_SPEED)
	GameRules:GetGameModeEntity():SetMinimumAttackSpeed(MINIMUM_ATTACK_SPEED)
	
	HeroSelection:StartHeroSelection()
	
	ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap( CRaidKings, "OnHeroPick"), CRaidKings )
end

function CRaidKings:OnHeroPick(event)
	local hero = EntIndexToHScript(event.heroindex)
	if not hero or hero:GetName() == "npc_dota_hero_wisp" then return end
	print("Hero loaded in: "..hero:GetName())
	StatsManager:CreateCustomStatsForHero(hero)
end