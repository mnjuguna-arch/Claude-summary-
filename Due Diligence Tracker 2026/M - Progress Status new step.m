// Investment Masterlist — replace your "Inserted conditional column" step (the last step) with this.
// Changes vs your version:
//   1. builds on #"Cleaned progressed_status" (your step skipped the status clean-up)
//   2. "Draft missing key KYC" / "Draft missing waiting more info" -> "Pending" instead of "Rejected"
// The "in" line at the bottom stays: #"Inserted conditional column"

  #"Inserted conditional column" = Table.AddColumn(#"Cleaned progressed_status", "Progress Status new", each
      if [progressed_status] = null or [progressed_status] = "" then null
      else if [progressed_status] = "Application completed and progressed" then "Application completed and progressed"
      else if Text.StartsWith([progressed_status], "Draft") then "Pending"
      else "Rejected", type nullable text)
