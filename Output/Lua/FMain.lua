
require "FPreload"

require "game.FGame"

function main( )
	local FGameUpdate = require "game.FGameUpdate"
	FGameUpdate.Instance():Run()
	
	theGame:Run()
end


