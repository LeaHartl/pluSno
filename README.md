# pluSno
Module 1:  modul1_pluSnow (calls subfunction to read data file, as well as fixgaps.m and several subfunctions contained in the main script.)
At the start of the script the location name has to be entered as a string variable. The script is setup to call a subfunction of the same name, which reads the data file for the station (the file structure is different for the various stations so it is not possible to use the same read commands for all stations). The subfunction needs to be set up before running module1.
Set variable ‘mm’ to d for daily means, to h for hourly means. If mm= ‘h’ and the variable “events” is set to 1, a separate output file is written containing means and sums of the various parameters  during single precipation events. Events are defined based on hourly values. The start time (yyyymmddHH) and the duration of the event in hours is given in the output file. Events are snowfalls with a minimum hourly snow rate (HNrate=0.5 cm/h) over the duration of the event. 24 hour time windows are considered. Example file name: events_20110101_20151202_kuehroint.txt

Subfunction: location.m (e.g. kuehtai.m, kuehroint.m, weissfluh.m)
In the location subfunction, the time step between data, and the start and end date are entered. The ‘textscan’ command is used to read the respective file.  
The data must start and end on the full hour and days must be complete. i.e. timeseries should start at midnight of the first day and end at 23:50 of the last day, when the time step is 10 minutes. If this is not the case or if there are gaps in the data an error message is printed.
The variables read from the data files and used in the script are:
Date and time. This is only used to check for gaps. A new timestamp vector is created later.
Output of ‘location’ subfunction: Snow height, snow pillow data, incoming shortwave radiation, relative humidity, air temperature, precipitation, wind speed.

Depending on what is set at the start of the file, either daily or hourly values are computed. For radiation, relative humidity, air temperature and wind speed the mean value is the mean of the previous hour/day. For precipitation it is the sum of the previous hour/day. For the snow pillow data the hourly value is the value at the full hour/ at the last time step of the day. A correction for radiation spikes is applied to the snow height: if the incoming sw radiation is over 30, snow height is set to an error value. Missing values are linearly interpolated in these cases. Snow height is smoothed using a centred moving average. The hourly/daily value for snow height is the value on the full hour/ at the last time step of the day, using the corrected and smoothed time series.
Output is written as a .mat file and to a tab separated text file of the following structure, into a folder called module1_out. The file name includes whether it contains hourly or daily means, the start and end date and the location. Example: h_20110101_20151202_kuehroint.txt
date	datenr	rad [w/m2]	relhum [%]	airtemp [°C]	windsp [m/s]	prec [mm]	pillow [mm]	snow [cm]	
2011010100	734504	NaN	NaN	NaN	NaN	NaN	NaN	NaN
2011010101	734504.04166666663	0	61.100000000000001	-1.3700000000000001	0.60999999999999999	0	10.18	44.18
 
Module 2: modul2_pluSnow (calls: wetbulb.m, edit_data.m, densities.m, makestats.m, sort_in_bins.m)
This reads the data files that are produced in module 1.
At the start of the file, the following variables are defined: location (needs to be spelled the same as in module 1, case sensitive). Alti= altitude of station. Threshold values for the change in snow pillow data, and new snow, wind speed and wet bulb temperature. A variable make_fig: if make_fig is set to 1, several figures are produced and saved as .fig and .jpg files. If the variable is something else, the figures are supressed. The variable “c” can either be h for hours, d for days or e for events (if c= e, sub function ‘edit_events’ is called.) Depending on what this is set to, the script reads the corresponding output files from module 1 (these have to exist for this to work!)
Variables a and b are  the start and end date of the data in the file. This must match the data in the file! A1 and b1 are the start and end dates of a subrange of the data that can be defined. Currently the script contains a1 and b1 values for the time periods to be discussed in the paper. Uncomment as needed. 
If something is wrong with the date ranges, an error message appears and the script stops.
Output from module 2 is saved into a subfolder, which is created in the module if it doesn’t already exist. Example folder name: kuehroint_20110101_20151202_hours
Subfunction: wetbulb.m
If the wet bulb temperature does not already exist in a file, it is computed using the subfunction wetbulb.m. The script checks for existing files so that wetbulb is not called by default, because wetbulb is relatively slow. A message appears if wetbulb is called.
Subfunction: edit_data4.m
Then the subfunction edit_data4.m is called. Thresholds are applied to the data and the new snow density is calculated. A compaction correction is applied . density (‘dichte’) and corrected density (‘dichte_corr’) are both passed to the main file. If make_fig is 1, three figures are produced and saved: Two histogram plots showing all data and the threshold values, i.e. where the data is cut off. A scatter plot of density and wind and density and temperature. 
Subfunction: densities.m
The subfunction densities.m computes density parametrizations from literature (Hedstrom, Diamond, laChapelle, Fassnacht, Jordan, Schmucki, lehning) using air temperature, wind and relative humidity as input.
Density outliers at 5 and 95% are cut off, new variables are called dichte95 and dichte_corr95 (with and without compaction correction).
Then, a linear fit model is applied to the density data (dichte95). The output from this is written to a text file. To add or remove predictor variables modify line 124 (variables to add to table structure called X and character array of variable names.) The matlab function stepwiselm performs (forwards) stepwise regression, see documentation (https://de.mathworks.com/help/stats/stepwiselm.html). It starts with a constant model (model contains only a constant term/intercept, density is specified as the response variable). It uses the p-value for an F-test of the change in the sum of squared error to decide whether to add or remove a term (default setting). The name –value pair ‘upper’, ‘linear’ describes the largest set of terms in the fit and is set to linear, i.e. variable combinations or quadratic terms are excluded. The ‘verbose’ variable determines what is displayed in the command window. Verbose 2 shows the actions evaluated at each step. The default thresholds to add and remove variables are used. (Using these values means that only the wetbulb temperature is used for the regression.)
A vector of densities predicted using the above model is stored in ‘dichte_pred’.

Subfunction: make_stats.m
The subfunction make_stats.m computes some common statistical values for the variables (densities, climate parameters) and writes these to text files (mean, median, standard deviation for each winter, summary). Notation: 2013 means winter 2013/14 from September 1 to August 31. It also writes tables of the pearson correlation coefficient and correlation p-value for all density variables to text files. 

If variable make_fig is one, figures are produced:
Subfunction: sort_in_bins.m
The subfunction sort_in_bins is called. This sorts densities into 1°C wetbulb temperature bins. A resulting scatter plot is produced and saved. Key statistics from the binned analysis are saved into a text file called bin_stats. First line of table in bin stats: p and r2 of unbinned temperature values vs corrected density. Second line: p and r2 of median (binned) temperature vs density. Third and forth lines: same for wind.

Following this, the triple plot used in the paper is produced and output is written to a tab separated textfile and to a .mat file in the subfolder

Module 3: modul3_pluSnow 
This reads the .mat output of module 3 (which has to be placed in a folder called ‘data’ to be read) and produces two box plots comparing results from the three stations, which are saved into the same “data” folder.
