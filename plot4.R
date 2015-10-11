
require("data.table")
library(data.table)

# setwd("C:/Users/tim.barry/Documents/GitHub/datasciencecoursera/C04_Explore/Code")


#---------------------------------  Download data to dedicated directory.


# Source-Remote location(s)
url_src_zip  <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
fil_src_zip  <- "exdata-data-household_power_consumption.zip"


# Source-Local location(s)
dir_src_data <- paste(getwd(), "PowerConsump", sep = "/")
flp_src_zip <- paste(dir_src_data, fil_src_zip, sep = "/")
fil_src_txt  <- "household_power_consumption.txt"
flp_src_txt <- paste(dir_src_data, fil_src_txt, sep = "/")

# If the subdirectory for the data doesn't exist, create it.
if (!dir.exists(dir_src_data)) {
    dir.create(dir_src_data)
}

# Download the sourze zip file to the Source-Local directory
if (!file.exists(flp_src_zip)) {
    download.file(url_src_zip, destfile = flp_src_zip)
}    

# If the .zip hasn't been unzipped to the .txt file, do so.
if (!file.exists(flp_src_txt)) {
    setwd(dir_src_data)
    unzip(flp_src_zip, overwrite=TRUE)
    setwd("..")
}    

#---------------------------------  Process data

# Read the .txt file into a data.table.
dt_powerraw <- fread(flp_src_txt, sep = ";", header = TRUE, na.strings = c("?",""))

# Change the datatype of "Date" from character to Date.
dt_powerraw$Date <- as.Date(as.character(dt_powerraw$Date), format = "%d/%m/%Y") 

#Now copy only 2007-02-01 and 2007-02-02 to a new smaller data.table.
dt_powertarg <- dt_powerraw[Date >= "2007-02-01" & Date <= "2007-02-02",]

#Free up memory and remove the raw.
rm(dt_powerraw)

#Create new date+time column in character format.
dt_powertarg$DateTime <- paste(as.character(dt_powertarg$Date), dt_powertarg$Time, sep=" ")  

#Data.Table doesn not support POSIXit as does the Data.Frame, so an extra conversion as.POSIXct() provided 
# by the datatable library must be referenced.
dt_powertarg$POSIXctDateTime <- as.POSIXct(strptime(dt_powertarg$DateTime, format = "%Y-%m-%d %H:%M:%S"))
# str(dt_powertarg)
# View(dt_powertarg)


# Open a .PNG file, 480x480 pixels.
png(
    filename = "plot4.png",
    width = 480, height = 480, units = "px"
)


# Define a 2 x 2 plot grid (2 rows of data, 2 columns)
par(mfrow = c(2, 2))    


# Add upper left plot.
plot(dt_powertarg$POSIXctDateTime, dt_powertarg$Global_active_power 
     , type="l"
     , xlab = ""
     , ylab = "Global Active Power"
)

# Add upper right plot.
plot(dt_powertarg$POSIXctDateTime, dt_powertarg$Voltage 
     , type="l"
     , xlab = "datetime"
     , ylab = "Voltage"
)


# Add lower left plot.
plot(dt_powertarg$POSIXctDateTime 
     , dt_powertarg$Sub_metering_1
     , type="n"
     , ylab = "Energy sub metering"
     , xlab = ""
)

# Add the colored lines.
lines(dt_powertarg$POSIXctDateTime, dt_powertarg$Sub_metering_1, col="black")
lines(dt_powertarg$POSIXctDateTime, dt_powertarg$Sub_metering_2, col="red")
lines(dt_powertarg$POSIXctDateTime, dt_powertarg$Sub_metering_3, col="blue")

# Add the legend.
legend("topright"
       , legend=c("Sub_metering_1","Sub_metering_2","Sub_metering_3")
       , col=c("black","red","blue")
       , lwd=1
       , cex = .7  #reduce the normal text size to 70% of original.
)


# Add lower right plot.
plot(dt_powertarg$POSIXctDateTime, dt_powertarg$Global_reactive_power 
     , type="l"
     , xlab = "datetime"
     , ylab = "Global_reactive_power"
)


# Close the file.
dev.off()



