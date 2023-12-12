%==========================================================================
% NECOFS TS Toolbox
%
% Create NECOFS TS data
% Step 1 : read data into sturct format in dataset, month
%          --- Pioneer Array
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-06-30
%
%==========================================================================

clc
clear


%------Settings
indir = '../input/pioneer_array';
outdir = '../output/step1/';
year = 2019;
ffvcom = '../input/gom5_grid.nc';
dataset = 'pioneer_array';

Smax = 37;
Smin = 0;
Tmax = 30;
Tmin = 0;

Longitude = [-70.7700 -70.7785 -70.7708 -70.8783 -70.8782 -70.8789 -70.8802];
Latitude  = [ 40.3649  40.1334  39.9394  40.3619  40.2267  40.0963  39.9365];
Depth = [95 130 452 90 127 148 453];

% Read the GOM5 grid
f = f_load_grid(ffvcom, 'Coordinate', 'Geo');

% Read the TS data
store_t = datenum(year, 1, 1) : 3/24 : datenum(year+1, 1, 1)-1e-5;
for i = 1 : 7
    
    % Longitude
    data0(i).lon = Longitude(i);
    % Latitude
    data0(i).lat = Latitude(i);
    
    store_z = 0 : 2 : Depth(i);
    
    fin = [indir '/ooi_' num2str(i) '_temperature.nc'];
    read_depth = -ncread(fin, 'z');
    read_time = ncread(fin, 'time')/3600/24 + datenum(1970, 1, 1);
    read_temperature = ncread(fin, 'sea_water_temperature_profiler_depth_enabled');
    
    [data0(i).depth, data0(i).time, data0(i).T] = obs_merge_zt(read_depth, read_time, read_temperature, 't', store_t, 'z', store_z);

    fin = [indir '/ooi_' num2str(i) '_salinity.nc'];
    read_depth = -ncread(fin, 'z');
    read_time = ncread(fin, 'time')/3600/24 + datenum(1970, 1, 1);
    read_salinity = ncread(fin, 'sea_water_practical_salinity_profiler_depth_enabled');
    [~,~, data0(i).S] = obs_merge_zt(read_depth, read_time, read_salinity, 't', store_t, 'z', store_z);

end


%------------------------------------------------------
% Step 1. Remove the obs out of domain.
px = [f.bdy_x{:}];
py = [f.bdy_y{:}];
data1 = obs_set_domain(data0, px, py);

for im = 1 : 12

    disp(['---' num2str(year) '-' num2str(im, '%2.2d')])
    clear data2 data3 data4 data
    
    %------------------------------------------------------
    % Step 2. Separate the data in month
    t1 = datenum(year, im, 1);
    t2 = datenum(year, im+1, 1);
    data2 = obs_set_time(data1, '>=', t1, '<', t2);

    %------------------------------------------------------
    % Step 3. Merge stations by location
    data3 = obs_merge_location(data2);

    %------------------------------------------------------
    % Step 4. Check the data quality (Smin-Smax, Tmin-Tmax)
    data4 = obs_set_minmax(data3, 'T', Tmin, Tmax, 'S', Smin, Smax);

    %------------------------------------------------------
    % Step 5. Remove the row/column with no data
    data = obs_clean(data4, ["T", "S"]);

    %------------------------------------------------------
    % Output
    if ~isempty(data)
        fout = [outdir dataset '_' num2str(year) num2str(im, '%2.2d') '.mat'];
        save(fout, 'data', '-v7.3')
    end
end






