local MODULE = GAS.Logging:MODULE()

MODULE.Category = "Printer"
MODULE.Name = "Destroyed"
MODULE.Colour = Color(217, 200, 11)

MODULE:Setup(function()
	MODULE:Hook("gprinter_destroyed", "Blogs_GPrinterTake", function(gold, isPolice ,attacker, amount, powner64)
		if isPolice then
			MODULE:Log("{1} " .. DarkRP.getPhrase("printer_log.destroyed1") .. (gold and DarkRP.getPhrase("printer.golden") or "") .. " " .. DarkRP.getPhrase("printer_log.destroyed2") .. " " .. DarkRP.formatMoney(amount), GAS.Logging:FormatPlayer(attacker), GAS.Logging:FormatPlayer(powner64))
		else
			MODULE:Log("{1} " .. DarkRP.getPhrase("printer_log.destroyed1") .. (gold and DarkRP.getPhrase("printer.golden") or "") .. " " .. DarkRP.getPhrase("printer_log.destroyed3") .. " " .. DarkRP.formatMoney(amount), GAS.Logging:FormatPlayer(attacker), GAS.Logging:FormatPlayer(powner64))
		end
	end)
end)

GAS.Logging:AddModule(MODULE) // This function adds the module object to the registry.