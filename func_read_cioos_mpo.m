%==========================================================================
% NECOFS TS Toolbox
%
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-03-02
%
% Updates:
%
%==========================================================================
function data = func_read_cioos_mpo(fin)

% fin = '../input/cioos/CIOOS_201912/mpoMaritimeStJohnCTD_erddap_ogsl_ca.csv';

data1 = readtable(fin);
% data(1,:) = [];

lon = data1.longitude;
lat = data1.latitude;
depth = data1.sea_floor_depth_below_sea_surface;
time = datenum(data1.time, 'yyyy-mm-ddTHH:MM:SSZ');
T = data1.sea_water_temperature;
S = data1.sea_water_practical_salinity;

data2 = obs_create(lon, lat, depth, time, 'T', T, 'S', S);

data = obs_merge_location(data2);