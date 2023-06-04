CreateConVar("wave_amount", 0, FCVAR_REPLICATED, "Total rounds amount.")
CreateConVar("wave_length", 0, FCVAR_REPLICATED, "Round length in seconds.")
CreateConVar("wave_post_end", 0, FCVAR_REPLICATED, "Seconds between round end and round start.")

timer.Create("NOT_SUPPORTED", 2, 0, function()
    MsgC(Color(255, 100, 100), "* THIS MAP IS NOT SUPPORTED *\n")
    MsgC(Color(255, 50, 50), "The current map is unsupported!\n")

    for _, v in pairs(player.GetAll()) do
        v:ChatPrint("* THIS MAP IS NOT SUPPORTED *")
        v:ChatPrint("The current map is unsupported!")
    end
end)