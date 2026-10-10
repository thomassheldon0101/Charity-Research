library(tidyverse)
setwd("/Users/thomassheldon/Desktop")

# Find every CSV inside the folder
csv_files <- list.files("Charity_Data", pattern = "\\.csv$",
                        recursive = TRUE, full.names = TRUE)

# Read them all into a named list of tibbles
all_tables <- csv_files |>
  set_names(~ str_remove(.x, "Charity_Data/") |> str_remove("\\.csv$")) |>
  map(~ read_csv(.x, locale = locale(encoding = "Latin1"),
                 show_col_types = FALSE))

# Create seperate lists
monthly_accounts <- all_tables[str_detect(names(all_tables), "Monthly_accounts")]
t3010_by_year    <- all_tables[str_detect(names(all_tables), "T3010_as of")]

# in t3010_by_year remove the "t3010 as of 2026-05-31" part so that we just have year/subject (ex. 2020/Gift)
names(t3010_by_year) <- str_remove(names(t3010_by_year), "T3010_as of 2026-05-31/")
names(t3010_by_year) <- str_remove(names(t3010_by_year), "as of 2026-05-31")

#create independent tibbles
financialABC_20 <- t3010_by_year$`2020/Financial Section A_ B and C`
financialD_20 <- t3010_by_year$`2020/Financial Section D & Schedule 6`
Schedule3_20 <- t3010_by_year$`2020/Schedule 3_ Compensation`
Ident_20 <- t3010_by_year$`2020/Ident`

# set BN/registration number to BN
financialABC_20 <- rename(financialABC_20, BN = "BN/Registration number")
financialD_20 <- rename(financialD_20, BN = "BN/Registration Number")
Schedule3_20 <- rename(Schedule3_20, BN = "BN/Registration number")
Ident_20  <- rename(Ident_20, BN = "BN/Registration Number")

#note on section D and schedule 6: the two are combined in the dataset. 
#variables whicha are only S6 will only include S6 charities
#variables wich are for both S6 and non S6 will have both 

# pull out columns from the independent tibbles
# if YES to C9_3400 then Sch3 must be completed. So charities which answer NO to C9_3400 do not complete Sch3
C9_3400_20 <- financialABC_20 %>% select("BN", "3400")
D3_4565_20 <- financialD_20 %>% select("BN", "4565")
D3_4570_20 <- financialD_20 %>% select("BN", "4570")
Sch3_300_20 <- Schedule3_20 %>% select("BN", "300")
Sch3_370_20 <- Schedule3_20 %>% select("BN", "370")
Sch3_380_20 <- Schedule3_20 %>% select("BN", "380")
Sch3_390_20 <- Schedule3_20 %>% select("BN", "390")

# join data sets by BN (key) 
joined_data1 <- left_join(D3_4565_20, D3_4570_20, by = "BN") %>% left_join(C9_3400_20, by = "BN") %>% left_join(Sch3_300_20, by = "BN") %>% left_join(Sch3_370_20, by = "BN") %>% left_join(Sch3_380_20, by = "BN") %>% left_join(Sch3_390_20, by = "BN")

# control variables 
D3_4700_20 <- financialD_20 %>% select("BN", "4700")
D4_4950_20 <- financialD_20 %>% select("BN", "4950")
A3_1600_20 <- financialABC_20 %>% select("BN", "1600")

      # recall, Schedule 6 data is in the Financial Section D tibble
Sch6_4540_20 <- financialD_20 %>% select("BN", "4540")
Sch6_4550_20 <- financialD_20 %>% select("BN", "4550")
Sch6_4560_20 <- financialD_20 %>% select("BN", "4560")
      # these three levels of gov funding must sum to total gov funding

postalcodes <- Ident_20 %>% select("BN", "Postal code")
provinces <- Ident_20 %>% select("BN", "Province")
registration_date <- Ident_20 %>% select("BN", "Registration date")
categorycodes <- Ident_20 %>% select("BN", "Category code", "Sub-category code")


