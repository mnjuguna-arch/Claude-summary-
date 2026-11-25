let
    Source = Odbc.Query("dsn=Clickhouse", "select * from due_diligence_loan_applications ddla "),
  #"Changed column type" = Table.TransformColumnTypes(Source, {{"phone_number", Int64.Type}, {"cd_date_of_birth", type date}, {"how_much_are_you_applying_for", Int64.Type}, {"loan_applied_on", type date}, {"starttime", type datetimezone}, {"endtime", type datetimezone}}),
  #"Cleaned progressed_status" = Table.TransformColumns(#"Changed column type", {{"progressed_status", each if _ = null then null else Text.Combine(List.Select(Text.Split(Text.Replace(_, "_", " "), " "), each _ <> ""), " "), type nullable text}})
in
    #"Cleaned progressed_status"
