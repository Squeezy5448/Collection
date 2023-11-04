--[[
  Example:
    You can basically add anything to your state.
    Also You don't really need to copy this unless you want to
    return {
	    ["Attacking"] = {
		    StartTime = os.clock(),
		    Duration =  0,

		    AllowedSkills = {},

		    Type = "NormalInteger"
	    },
	    ["Blocking"] = {
		    StartTime = os.clock(),
		    Duration = 0,

		    BlockVal = 1000,
		    IsBlocking = false,

		    Type = "Boolean"
	    },
	    ["Dashing"] = {
	    	StartTime = os.clock(),
		    Duration =  0,

		    Type = "NormalInteger"
	    },
	    ["Guardbroken"] = {
		    StartTime = os.clock(),
		    Duration =  0,

		    Type = "NormalInteger"
	    },
	    ["LastHit"] = {
		    StartTime = os.clock(),
		    Duration =  .5,

		    LastTarget = "",
		    LastDamaged = 0,

		    Type = "SpecialInteger"
	    }
    }  
--]]

return {}
