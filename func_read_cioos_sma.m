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
function data = func_read_cioos_sma(fin)

% fin = '../input/cioos/CIOOS_201912/SMA_halifax_cioosatlantic_ca.csv';

data1 = readtable(fin);
% data(1,:) = [];

lon = data1.longitude;
lat = data1.latitude;
depth = lon*0;
time = datenum(data1.time, 'yyyy-mm-ddTHH:MM:SSZ');
T = data1.surface_temp_avg;
S = nan * T;

data2 = obs_create(lon, lat, depth, time, 'T', T, 'S', S);

data = obs_merge_location(data2);