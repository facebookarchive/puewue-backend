module CSVFixtures
  def csv_header
    %q{Timestamp,PUE,WUE,Temp,humidity,UtilKWh,ITKWh,TotaWaterUsage}
  end

  def one_entry
    [
      csv_header,
      "2012-12-25 03:46:00.000,1.08,0.47,29.6,76.88,297.56,275.16,0.00"
    ].join("\n")
  end

  def entry_missing
    [
      csv_header,
      "2012-12-25 03:46:00.000,1.08,,29.6,76.88,297.56,275.16,0.00"
    ].join("\n")
  end
end
