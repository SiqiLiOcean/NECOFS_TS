%==========================================================================
% NECOFS TS Toolbox
%
% Create NECOFS TS data
% Step 1 : read data into sturct format in dataset, month
%          --- BIO
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-06-30
%
%==========================================================================

clc
clear

%------Settings
fin1 = '../input/bio/UMASS_TEMP.xlsx';
fin2 = '../input/bio/UMASS_SAL.xlsx';
outdir = '../output/step1/';
year = 2019;
ffvcom = '../input/gom5_grid.nc';
dataset = 'bio';

Smax = 37;
Smin = 0;
Tmax = 30;
Tmin = 0;


% Read the GOM5 grid
f = f_load_grid(ffvcom, 'Coordinate', 'Geo');

% Read the TS data
sheet_list1 = ["Browns_Bank_Stns", "Louisbourg_Line", "Halifax_Line+Stn_2", "Prince_5"];
sheet_list2 = ["Browns_Bank_SAL", "Halifax_Line_Stn_2", "Louisbourg_Line", "Prince_5"];

for i = 1 : length(sheet_list1)
    table1 = readtable(fin1, 'Sheet', sheet_list1{i});
    data_T{i} = func_bio_table2data(table1, 1);
    table2 = readtable(fin2, 'Sheet', sheet_list2{i});
    data_S{i} = func_bio_table2data(table2, 2);
end
data_T = [data_T{:}];
data_S = [data_S{:}];

data0 = obs_join_var(data_T, 'T', data_S, 'S');





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






