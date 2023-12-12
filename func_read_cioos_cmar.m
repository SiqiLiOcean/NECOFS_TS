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
function data = func_read_cioos_cmar(fin)

% fin = '../input/cioos/CIOOS_201912/cmar_fca0_698a_0716_cioosatlantic_ca.csv';

data1 = readtable(fin);
data1(1,:) = [];

lon = data1.longitude;
lat = data1.latitude;
depth = lon*0;
time = datenum(data1.time, 'yyyy-mm-ddTHH:MM:SSZ');
T = data1.sea_water_temperature;
S = nan * T;

data2 = obs_create(lon, lat, depth, time, 'T', T, 'S', S);

data = obs_merge_location(data2);