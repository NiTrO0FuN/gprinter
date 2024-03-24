// Used for server-side text

local phrases = {
    en = {
        ["printer.spawned_golden"]="You just got a golden printer!",
        ["printer.cop_destroy"]="You got back $4000 for destroying a printer!",
        ["printer.took1"]="You took",
        ["printer.took2"]="from the printer",
        ["printer.golden"]=" golden",

        ["printer_seller.cannot_buy"]="You can't buy a printer yet",
        ["printer_seller.not_enough_money"]="You don't have enough money to buy a printer",
        ["printer_seller.strike"]="Printer sellers are on strike at the moment",
        ["printer_seller.called"]="You called a printer seller, hurry up and reach him! \nIts position is indicated by a green circle!",
        ["printer_seller.please_wait"]="Please wait before contacting a printer seller again",

        ["printer_log.destroyed1"]="destroyed a",
        ["printer_log.destroyed2"]="printer belonging to {2} and received a reward of",
        ["printer_log.destroyed3"]="printer belonging to {2} having",

        ["printer_log.took1"]="{1} took",
        ["printer_log.took2"]="of a",
        ["printer_log.took3"]="printer belonging to {2}"
    },
    
    fr = {
        ["printer.spawned_golden"]="Vous avez fait apparaitre un printer doré !",
        ["printer.cop_destroy"]="Vous avez récupéré $4000 pour avoir détruit un printer !",
        ["printer.took1"]="Vous avez récupéré",
        ["printer.took2"]="dans le printer",
        ["printer.golden"]=" doré",

        ["printer_seller.cannot_buy"]="Tu ne peux pas encore acheter de printer",
        ["printer_seller.cannot_buy_as_police"]="Tu ne peux acheter de printer en tant que force de l'ordre!",
        ["printer_seller.not_enough_money"]="Vous n'avez pas assez d'argent pour acheter un printer",
        ["printer_seller.strike"]="Les vendeurs de printers sont en grève pour le moment",
        ["printer_seller.called"]="Vous avez appelé un vendeur d'imprimantes, dépêchez vous d'aller le rejoindre ! \nSa position est indiquée par un cercle vert !",
        ["printer_seller.please_wait"]="Veuillez attendre avant de recontacter un marchand",
        
        ["printer_log.destroyed1"]="a détruit le printer",
        ["printer_log.destroyed2"]="de {2} et a obtenu une récompense de",
        ["printer_log.destroyed3"]="de {2} qui contenait",

        ["printer_log.took1"]="{1} a retiré",
        ["printer_log.took2"]="d'un printer",
        ["printer_log.took3"]="de {2}"
    }
}

hook.Add("DarkRPFinishedLoading", "addGPrinterTranslations", function()
    for lang, translations in pairs(phrases) do
        for key, translation in pairs(translations) do
            DarkRP.addPhrase(lang, key, translation)
        end
    end
end)

