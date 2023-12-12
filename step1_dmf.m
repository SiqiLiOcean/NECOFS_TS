%==========================================================================
% NECOFS TS Toolbox
%
% Create NECOFS TS data
% Step 1 : read data into sturct format in dataset, month
%          --- DMF
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-06-30
%
%==========================================================================

clc
clear

%------Settings
fin = '../input/dmf/DMF_Invertebrate_Project_2019-2021.xlsx';
outdir = '../output/step1/';
year = 2019;
ffvcom = '../../restart/gom5_cold_restart_0001.nc';
dataset = 'dmf';

Smax = 37;
Smin = 0;
Tmax = 30;
Tmin = 0;

sta_id = [6 8 2 4 3 1 7 5 9];


% Read the GOM5 grid
f = f_load_grid(ffvcom, 'Coordinate', 'Geo');

% Read the TS data
table0 = readtable(fin, 'Sheet','DMF Invertebrate Project Temp');
info0 = readtable(fin, 'Sheet','Metadata');
time0 = datenum(table0{:,1});
time0 = time0 + 5/24;   % convert time from EST to GMT
table0 = table0{:, 3:11};

for i = 1 : length(sta_id)
    % Longitude
    data0(i).lon = info0.Long(sta_id(i));
    % Latitude
    data0(i).lat = info0.Lat(sta_id(i));
    % Depth
    
    data0(i).depth = info0.Depth(sta_id(i));
    % Time
    data0(i).time = time0;
    % Temperature
    data0(i).T = table0(:, sta_id(i))';
    % Salinity
    data0(i).S = nan(size(time0))';
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






