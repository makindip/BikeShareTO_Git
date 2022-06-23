from mysql_server_populate import populate_mysql_server, populate_mysql_server_key, get_mysql_server, get_dict_entry
import pandas as pd 
"""
The system includes 6,850 bikes, 625 stations with 12,000 docking points. Bike Share Toronto stations are located in 
Toronto, East York, Scarborough, North York, York and Etobicoke.
"""
# Populate mysql server with the trip history(2016-2022)
populate_mysql_server_key()
populate_mysql_server(2016)

# failed or corrupted files
file_2020_10='data/bikeshare-ridership-2020/2020-10.csv'
file_2021_01='data/bikeshare-ridership-2021/2021-01.csv'
file_2021_05='data/bikeshare-ridership-2021/2021-05.csv'
file_list=[file_2020_10,file_2021_01,file_2021_05]

for file in file_list:
    print(file)
    data_csv = pd.read_csv(file, encoding='utf-8')
    db_columns = get_dict_entry(data_csv.columns)
    data_csv.rename(columns=db_columns, inplace=True)
    data_csv['start_date'] =  pd.to_datetime(data_csv['start_date'], errors='ignore', infer_datetime_format=True)
    data_csv['end_date'] =  pd.to_datetime(data_csv['end_date'], errors='ignore', infer_datetime_format=True)
    data_csv.set_index('trip_id')
    data_csv.astype(object).where(pd.notnull(data_csv), None)
    data_csv.to_sql('trip_hist_err', get_mysql_server(), if_exists='append', index=False)