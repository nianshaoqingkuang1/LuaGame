
require "FPreload"

require "game.FGame"

function main( )
	local FGameUpdate = require "patches.FGameUpdate"
	FGameUpdate.Instance():Run()

	local co = coroutine.create(function ( )
		Yield(WaitUntil(function() return FGameUpdate.Instance():IsFinished() end))
		GameUtil.RunInMainThread(function()
			warn("在主线程中运行，开始游戏。")
			theGame:Run()
		end)
	end)

	coroutine.resume(co)
	--[[GameUtil.WaitCall(function() return FGameUpdate.Instance():IsFinished() end, function()
		theGame:Run()
		local co3, ismain = coroutine.running()
		print("co3",co3,ismain)
	end)]]
end


