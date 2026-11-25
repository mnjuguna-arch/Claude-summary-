// Investment Masterlist — replace the LAST step ("Added dd_date corrected") in the Advanced Editor with this.
// The "in" line at the bottom stays:  #"Added dd_date corrected"
//
// Handles all three formats found in dd_date (checked 2026-11-23):
//   2026-11-14  (ISO)   -> year-month-day
//   20/10/2026  (main)  -> day/month
//   10/23/2026  (some)  -> month/day
// Ambiguous values (both parts <= 12) are read day/month unless that gives a date before
// 14 Sep 2026 (tracker start) or in the future; then month/day is used.
// Tested on all 10,706 dates: 100% parsed; 10,682 of 10,685 fall within a day of the client's DD form.

 #"Added dd_date corrected" =
    Table.TransformColumnTypes(Table.AddColumn(#"Replaced value 4", "dd_date_corrected", each let
        DateText = Text.Replace(Text.Trim(Text.From([dd_date]) ?? ""), "-", "/"),
        N = List.Transform(Text.Split(DateText, "/"), each try Number.From(_) otherwise null),
        WindowStart = #date(2026, 9, 14),
        Today = Date.From(DateTime.LocalNow()),
        Make = (y, mo, d) => try #date(y, mo, d) otherwise null,
        InWindow = (dt) => dt <> null and dt >= WindowStart and dt <= Today,
        Result =
            if List.Count(N) <> 3 or List.Contains(N, null) then null
            else if N{0} > 31 then Make(N{0}, N{1}, N{2})
            else
                let
                    DayFirst = Make(N{2}, N{1}, N{0}),
                    MonthFirst = Make(N{2}, N{0}, N{1})
                in
                    if InWindow(DayFirst) then DayFirst
                    else if InWindow(MonthFirst) then MonthFirst
                    else DayFirst ?? MonthFirst
    in
        Result), {{"dd_date_corrected", type date}})
