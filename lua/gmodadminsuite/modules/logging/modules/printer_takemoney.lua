local MODULE = GAS.Logging:MODULE()

MODULE.Category = "Printer"
MODULE.Name = "Take money"
MODULE.Colour = Color(217, 200, 11)

MODULE:Setup(function()
	MODULE:Hook("gprinter_take_money", "Blogs_GPrinterTake", function(gold, user, amount, powner64)
		MODULE:Log(DarkRP.getPhrase("printer_log.took1") .. " " .. DarkRP.formatMoney(amount) .. " " .. DarkRP.getPhrase("printer_log.took2") .. (gold and DarkRP.getPhrase("printer.golden") or "") .. " " .. DarkRP.getPhrase("printer_log.took3"), GAS.Logging:FormatPlayer(user), GAS.Logging:FormatPlayer(powner64))
	end)
end)

GAS.Logging:AddModule(MODULE) // This function adds the module object to the registry.