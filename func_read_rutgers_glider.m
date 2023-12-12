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
function obs = func_read_rutgers_glider(fin)

% clc
% clear
% 
% fin = '../input/rutgers_glider/bios_anna-20190606T1502.nc';

window_t = 10 / 60 / 24; 
window_z = 0.5;
window_d = 0.01;
delta_t = 60 / 60 / 24;
delta_z = 2;
delta_d = 0.01;


lon0 = ncread(fin, 'longitude');
lat0 = ncread(fin, 'latitude');
depth0 = ncread(fin, 'depth');
time0 = ncread(fin, 'time')/3600/24 + datenum(1970,1,1);
T0 = ncread(fin, 'temperature');
S0 = ncread(fin, 'salinity');



% Time
t1 = floor(min(time0));
t2 = ceil(max(time0));
t = t1 : delta_t : t2;

[it, dt] = knnsearch(t(:), time0(:));
k1 = dt<=window_t;

time1 = t(it(k1));
lon1 = lon0(k1);
lat1 = lat0(k1);
depth1 = depth0(k1);
T1 = T0(k1);
S1 = S0(k1);

% Depth
z1 = 0;
z2 = ceil(max(depth0)+delta_z);
z = z1 : delta_z : z2;

[iz, dz] = knnsearch(z(:), depth1(:));
k2 = dz<=window_z;

depth2 = z(iz(k2));
lon2 = lon1(k2);
lat2 = lat1(k2);
time2 = time1(k2);
T2 = T1(k2);
S2 = S1(k2);

% Location
x = lon2(1);
y = lat2(1);
for i = 2 : length(lon2)
    dd = sqrt((x-lon2(i)).^2 + (y-lat2(i)).^2);
    if min(dd)> delta_d
        x = [x; lon2(i)];
        y = [y; lat2(i)];
    end
end

[id, dd] = knnsearch([x y], [lon2 lat2]);
k3 = dd<window_d;

lon3 = lon2(id(k3));
lat3 = lat2(id(k3));
depth3 = depth2(k3);
time3 = time2(k3);
T3 = T2(k3);
S3 = S2(k3);

data0 = obs_create(lon3, lat3, depth3, time3, 'T', T3, 'S', S3);

% Calculate the mean value for the same location, depth and time
obs = obs_mean_var(data0);
