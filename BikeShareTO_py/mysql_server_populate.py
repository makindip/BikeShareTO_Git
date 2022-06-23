## imports
import os
import pandas as pd
import numpy as np
import pymysql
from sqlalchemy import create_engine
from decouple import config

def get_mysql_server():
  """
  establishes contact with the mysql server.
  """
  user = config('userID',default='')
  password = config('password',default='')
  engine = create_engine('mysql+pymysql://' + user + ':' + password + '@localhost/BikeShareTO')# db destination
  conn = engine.connect()
  return conn

# normalize the naming conventions from various source files
def get_dict_entry(oldColumns):
  """
  Contructs a dictionary used to map naming conventions to normalized column names
  """
  # create the dict(), convert pd.Index() to list()
  newColumns = dict()
  oldColumns = [x for x in oldColumns.tolist()]
  # use decision graph to identify existing columns
  for item in oldColumns:
    if any(substr.casefold() in item.casefold() for substr in ['start','from']):# start info
      if any(substr.casefold() in item.casefold() for substr in ['date','time']):
        newColumns.update({item:'start_date'})
      else: 
        if ('id'.casefold() in item.casefold()):
            newColumns.update({item:'start_station_id'})
        else:
            newColumns.update({item:'start_station_name'})
    elif any(substr.casefold() in item.casefold() for substr in ['end','to','stop']):# destination info
      if any(substr.casefold() in item.casefold() for substr in ['date','time']):
        newColumns.update({item:'end_date'})
      else:
        if ('id'.casefold() in item.casefold()):
          newColumns.update({item:'end_station_id'})
        else:
          newColumns.update({item:'end_station_name'})
    else:
      if all(substr.casefold() in item.casefold() for substr in ['trip','id']):# customer info
        newColumns.update({item:'trip_id'})
      elif ('duration'.casefold() in item.casefold()):
        newColumns.update({item:'duration'})
      elif ('bike'.casefold() in item.casefold()):
        newColumns.update({item:'bike_id'})
      elif ('type'.casefold() in item.casefold()):
        newColumns.update({item:'member_type'}) 
      else:
        continue
  return newColumns

# move Station key
def populate_mysql_server_key():
  foldername = 'bikeshare-locations/'
  path = 'data/' + foldername 
  data_csv = pd.read_csv(path + 'station_key_2016.csv')
  db_columns= dict(zip(data_csv.columns.to_list(), [item.lower() for item in data_csv.columns.to_list()]))
  data_csv.rename(columns=db_columns, inplace=True)
  data_csv.set_index('terminal')
  data_csv.to_sql('station_key', get_mysql_server(), if_exists='replace', index=False)

  
# Move the dataset to mysql server:
def populate_mysql_server(start_year=2022):
  """
  start_year - 2016, 2017, 2018, 2019, 2020, 2021, 2022
  default - 2022 
  This function populates the mysql server on my localhost with the trip history 
  from BikeShareTO. This data source is an amalgamation of xlsx and csv files, with varied
  naming conventions this is an attempt to streamline them into a single database. Not all 
  DataFrames are created equal, column order may vary also columns may be missing.
  """
  # db_columns=['trip_id','duration','start_station_id','trip_start_date','start_station_name',
              # 'end_station_id','trip_end_date','end_station_name','bike_id','member_type']
  if start_year == 2022:
    filename = 'bikeshare-ridership-' + str(start_year)
    path = 'data/' + filename 
    for i in range(1,13,1):
      if os.path.exists(path + '/{year}-{month:02}.csv'.format(year=start_year, month=i)):
        try: 
          print('starting', i)
          data_csv = pd.read_csv(path + '/{year}-{month:02}.csv'.format(year=start_year, month=i))
          db_columns = get_dict_entry(data_csv.columns)
          data_csv.rename(columns=db_columns, inplace=True)
          data_csv['start_date'] =  pd.to_datetime(data_csv['start_date'], errors='ignore', infer_datetime_format=True)
          data_csv['end_date'] =  pd.to_datetime(data_csv['end_date'], errors='ignore', infer_datetime_format=True)
          data_csv.set_index('trip_id')
          data_csv.astype(object).where(pd.notnull(data_csv), None)
          data_csv.to_sql('trip_hist', get_mysql_server(), if_exists='append', index=False)
        except:
          print('error')
  else:
    for j in range(start_year, 2023, 1):
      filename = 'bikeshare-ridership-' + str(j)
      path = 'data/' + filename
      for k in range(1,13,1):
        if os.path.exists(path + '/{year}-{month:02}.csv'.format(year=j, month=k)): 
          try:
            print('starting', j, k)
            data_csv = pd.read_csv(path + '/{year}-{month:02}.csv'.format(year=j, month=k))
            db_columns = get_dict_entry(data_csv.columns)
            data_csv.rename(columns=db_columns, inplace=True)
            data_csv['start_date'] =  pd.to_datetime(data_csv['start_date'], errors='ignore', infer_datetime_format=True)
            data_csv['end_date'] =  pd.to_datetime(data_csv['end_date'], errors='ignore', infer_datetime_format=True)
            data_csv.set_index('trip_id')
            data_csv.astype(object).where(pd.notnull(data_csv), None)
            data_csv.to_sql('trip_hist', get_mysql_server(), if_exists='append', index=False)
          except:
            print('error')
        else:
          continue

if __name__=='__populate_mysql_server__':
  populate_mysql_server()