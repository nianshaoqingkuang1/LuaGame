
require "FPreload"

require "game.FGame"

function main( )
	local co1, ismain = coroutine.running()
	print("co1",co1,ismain)

	local FGameUpdate = require "game.FGameUpdate"
	FGameUpdate.Instance():Run()

	local co2, ismain = coroutine.running()
	print("co2",co2,ismain)

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


