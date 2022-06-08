# Description
This project uses data accessed through Toronto's Open Data Portal, it includes information 
on BikeShareTO's ridership over a number of year. Their system includes 6,850 bikes, 
625 stations with 12,000 docking points. Bike Share Toronto stations are located
in Toronto, East York, Scarborough, North York, York and Etobicoke.

There is a variation between the information included in each year. This is due 
to a change in software providers in July 2016, and the data collection/reporting methods 
are different compared to previous years. This data varies in documentation from year
to year. While 2016 - 2019 is provided in quarters, 2020 and beyond is provided as monthly data. 

Reflected in the list below are columns name, as outlined by me for the db, the column names 
have been transformed to refelect the ones below.
 
| Column Name | Type | Description |
|:------------|:-----|:-------------------------|
| trip_id| integer| unique integer identifying a trip (primary key)|
| start_date| datetime| Start time and date of a trip|
| end_date| datetime|	End time and date of a trip|
| duration| integer|	Duration of a trip (in seconds)|
| start_station_name| string| Name of the station where the trip started (origin)|
| end_station_name| string| Name of the station where the trip ended (destination)|
| bike_id| integer| unique integer	identifying a bike (foreign key)|
| member_type| string| The type of user that took the trip|

I intend to combine data sources, for example with weather reportage later in the project.