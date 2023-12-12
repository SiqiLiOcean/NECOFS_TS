%==========================================================================
% NECOFS TS Toolbox
%
% Step 1 : read data into sturct format in dataset, month
%          --- SMAST_Pinngguo
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-06-30
%
%==========================================================================

clc
clear


%------Settings
fin = '../input/smast_pingguo/VW_Temp_Tow_Data.xlsx';
outdir = '../output/step1/';
year = 2019;
ffvcom = '../input/gom5_grid.nc';
dataset = 'smast_pingguo';

Smax = 37;
Smin = 0;
Tmax = 30;
Tmin = 0;


% Read the GOM5 grid
f = f_load_grid(ffvcom, 'Coordinate', 'Geo');

% Read the TS data
table0 = readtable(fin);
%
StartTime = datenum (table0{:,7});
EndTime = datenum(table0{:,11});
Time = (StartTime + EndTime) / 2;
Time = Time + 6/24;   % Convert time from EST to GMT.
%
StartLongitude = func_pingguo_degreeStr2num(table0{:,9});
EndLongitude = func_pingguo_degreeStr2num(table0{:,13});
Longitude = (StartLongitude + EndLongitude) / 2;
%
StartLatitude = func_pingguo_degreeStr2num(table0{:,8});
table0{261, 12} = {'N 40⁰52.967'};
EndLatitude = func_pingguo_degreeStr2num(table0{:,12});
Latitude = (StartLatitude + EndLatitude) / 2;
% 
StartDepth = table0{:,10};
EndDepth = table0{:,14};
Depth = (StartDepth + EndDepth) / 2;
%
Temperature = table0{:,17};

for i = 1 : length(Time)
    data0(i).lon = Longitude(i);
    data0(i).lat = Latitude(i);
    data0(i).depth = Depth(i);
    data0(i).time = Time(i);
    data0(i).T = Temperature(i);
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






