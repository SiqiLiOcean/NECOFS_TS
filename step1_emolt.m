%==========================================================================
% NECOFS TS Toolbox
%
% Create NECOFS TS data
% Step 1 : read data into sturct format in dataset, month
%          --- eMolt
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-06-30
%
%==========================================================================

clc
clear

%------Settings
fin = '../input/emolt/eMOLT_2019.nc';
outdir = '../output/step1/';
year = 2019;
ffvcom = '../input/gom5_grid.nc';
dataset = 'emolt';

Smax = 37;
Smin = 0;
Tmax = 30;
Tmin = 0;


% Read the GOM5 grid
f = f_load_grid(ffvcom, 'Coordinate', 'Geo');

% Read the TS data
read_lon = ncread(fin, 'longitude');
read_lat = ncread(fin, 'latitude');
read_depth = ncread(fin, 'depth');
read_time = ncread(fin, 'time')/3600/24 + datenum(1970, 1, 1);
read_temperature = ncread(fin, 'sea_water_temperature');

for i = 1 : length(read_time)
    data0(i).lon = read_lon(i);
    data0(i).lat = read_lat(i);
    data0(i).depth = read_depth(i);
    data0(i).time = read_time(i);
    data0(i).T = read_temperature(i);
    data0(i).S = nan;
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






