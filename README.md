## mexineq Repository

### Purpose
Create maps and plot about the income threshold of the top 1% by Mexican States. 

### Data
Modulo de Condiciones Socioeconomicas INEGI available [here](http://www3.inegi.org.mx/sistemas/microdatos/micdirecto.aspx?s=est&c=34529).
Remember to download the databases in .dbf format, in order to run the R script.

The databases of the MCS was replaced in september 2015 because of an existing errors in some variables.

Specifically, this R script uses the "concentrado" database, which contains summary and main variables at a houshold level.

The geographic data (shapefiles) si available at [GADM](http://gadm.org). Remember to download the data in shapefile format.

### Figures
A state-level Map and a Cleveland dot plot are provided in .png format.