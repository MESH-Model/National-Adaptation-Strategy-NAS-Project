# CanESM5-Figures

A repository containing test code for generating SSP comparison figures based on input data from CanESM5.

## Generating Figures

1.    Create a folder titled "CanESM5" in your parent directory. This is where the code will search for your input `.csv` files
2.    In your virtual environment, run `pip install -r requirements.txt` from the script directory
3.    Open Python and run `import cmip-postprocessing as cmip`
4.    Run the function `cmip.generate_plot('<station_id>')`, where `<station_id>` is the 7-digit identifier used by ECCC
5.    Alternatively, run the list comprehension `dummy = [generate_plot(plot) for plot in ['<list_of_ids>']]` to generate multiple
6.    A list of applicable stations is available in the file`station_metadata.csv`

## Credit

- Scripts by Riley Damen (Riley.Damen@ec.gc.ca)
- Original data by Sujata Budhathoki (Sujata.Budhathoki@ec.gc.ca)
