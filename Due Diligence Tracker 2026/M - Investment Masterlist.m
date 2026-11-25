let
    Source = Odbc.Query("dsn=Clickhouse", "select distinct * from surveycto_investment_clients_masterlist sicm "),
  #"Changed column type" = Table.TransformColumnTypes(Source, {{"record_id", Int64.Type}, {"phone_number", Int64.Type}}),
  #"Replaced value" = Table.ReplaceValue(#"Changed column type", ",", "", Replacer.ReplaceText, {"recruitment_year"}),
  #"Replaced value 1" = Table.ReplaceValue(#"Replaced value", "_", " ", Replacer.ReplaceText, {"region"}),
  #"Uppercased text" = Table.TransformColumns(#"Replaced value 1", {{"cd_location", each Text.Upper(_), type nullable text}}),
  #"Added custom" = Table.AddColumn(#"Uppercased text", "Refugee Vs Host", each if [strata] = "Host" or
   [strata] = "Host Community"
then "Host"

else if List.Contains(
    {
        "Camp based refugee",
        "Camp_based_refugee",
        "Camp-based refugee",
        "Refugee (camp based)",
        "Urban based refugee",
        "Urban-based refugee",
        "Urban refugee",
        "Refugee",
        "Asylum seeker",
        "Internally displaced persons",
        "IDP",
        "Returnees refugees",
        "Returnee_refugee"
    },
    [strata]
)
then "Refugee"

else if [strata] = "Secondary cities"
then "Secondary cities"

else null),
  #"Replaced value 2" = Table.ReplaceValue(#"Added custom", "_", " ", Replacer.ReplaceText, {"progressed_status"}),
  #"Replaced value 3" = Table.ReplaceValue(#"Replaced value 2", " Province", "", Replacer.ReplaceText, {"region"}),
  #"Replaced value 4" = Table.ReplaceValue(#"Replaced value 3", "irobi", "Nairobi", Replacer.ReplaceValue, {"region"}),

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
        Result), {{"dd_date_corrected", type date}}),
  #"Cleaned progressed_status" = Table.TransformColumns(#"Added dd_date corrected", {{"progressed_status", each if _ = null then null else Text.Combine(List.Select(Text.Split(Text.Replace(_, "_", " "), " "), each _ <> ""), " "), type nullable text}})
in
    #"Cleaned progressed_status"

