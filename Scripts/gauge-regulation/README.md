# Dam Drainage and Gauge Regulation Calculator

"regulation_calculator.py" uses aggregated subbasin data from the North American Land-River Routing Product (NALRRP)
or Canadian Land-River Hydrofabric (CLRH) [1] retrieved from BasinMaker 3.0 [2] to calculate the degree of flow
regulation for documented stream gauges within a defined region.

## Description

The project uses the dimensionless "Dam Index" (DI) method developed by Marti and Ryberg [3], which defines regulation
level as a function of total drainage area, upstream reservoir volume, upstream reservoir drainage area, and mean
upstream annual precipitation. All of the required parameters are extracted from the input NALRRP or CLRH shapefiles
[1], with the exception of precipitation, which is sourced from Agriculture and Agri-Food Canada [4]. Tools from
several external Python libraries are leveraged, including pandas by Wes McKinney [5], GeoPandas by Kelsey Jordahl [6],
and exactextract by Dan Baston [7].

## Usage

1.  Select the region(s) of interest on the BasinMaker 3.0 website and choose "routing product (zip)" [2]:
	https://hydrology.uwaterloo.ca/basinmaker/download_regional.html

2.  If not using the included file from Agriculture and Agri-Food Canada [4], retrieve 30-year annual average
	precipitation raster from any external source.

3.  Extract the downloaded routing product folder(s), and open the files "finalcat_info_vX-X.shp" and
	"obs_gauges_vX-X.shp" in any GIS software (QGIS, ArcGIS, etc.). The loaded files represent the subbasin
	geometries and the stream gauge locations, respectively.
	
4.  Preprocess the data as necessary. Ensure the vector and raster files use the same coordinate system. The provided
	precipitation file uses NAD83 (WKID: 4269).
	
5.  Export the three files to the same directory, with titles "basins.shp", "gauges.shp", and "precipitation.tif",
	respectively. Copy the directory.
	
6.  Run the program, and past the directory into the input prompt. The output "gauges_DI.csv" file will be located in
	the same directory.
	
7.  To visualize the results in a GIS software, join the tables with field "SubId". The calculated DI values fall on a
	spectrum, but a threshold may be selected to split the dataset at the level where degree of regulation is
	considered significant.

## Authors

Program and workflow created by Riley Damen at Environment and Climate Change Canada. Riley.Damen@ec.gc.ca

## Acknowledgements

[1] M. Han et al., “North American Lake-River Routing Product v 2.1, derived by BasinMaker GIS Toolbox.” Zenodo, Feb.
	14, 2020. doi: 10.5281/ZENODO.4728185.
	
[2] M. Han et al., “BasinMaker 3.0: A GIS toolbox for distributed watershed delineation of complex lake-river routing
	networks,” Environmental Modelling & Software, vol. 164, p. 105688, Jun. 2023, doi: 10.1016/j.envsoft.2023.105688.
	
[3] M. K. Marti and K. R. Ryberg, “Method for identification of reservoir regulation within U.S. Geological Survey
	streamgage basins in the Central United States using a decadal dam impact metric,” U.S. Geological Survey,
	2023–1034, 2023. doi: 10.3133/ofr20231034.
	
[4] Agriculture and Agri-Food Canada, “Derived Normal Climate Data.” Pre-packaged GeoTIF Grid files (No linguistic
	component), Jun. 17, 2024. Accessed: Jul. 28, 2025. [Online]. Available:
	https://open.canada.ca/data/en/dataset/3a060b8f-e662-4a60-b297-3bed859ffc8a
	
[5] W. McKinney and the pandas development team, pandas documentation — pandas 2.3.1. (Jul. 07, 2025). Python.
	Accessed: Jul. 28, 2025. [Online]. Available: https://pandas.pydata.org/docs/
	
[6] K. Jordahl and the GeoPandas development team, Documentation — GeoPandas. (Jun. 27, 2025). Python. Accessed: Jul.
	28, 2025. [Online]. Available: https://geopandas.org/en/stable/docs.html
	
[7] D. Baston, exactextract — exactextract documentation. (Apr. 27, 2025). ISciences. Accessed: Jul. 28, 2025.
	[Online]. Available: https://isciences.github.io/exactextract/
