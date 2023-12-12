%==========================================================================
% NECOFS TS Toolbox
%
% Create NECOFS TS data
% Step 1 : read data into sturct format in dataset, month
%          --- MWRA
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-06-30
%
%==========================================================================

clc
clear

%------Settings
fin = ["../input/mwra/2019_BH_DREQ_BEM_HYDRO_ONLY_20220616.xlsx" ...
       "../input/mwra/2019_MB_DREQ_BEM_HYDRO_ONLY_20220616.xlsx"];
outdir = '../output/step1/';
year = 2019;
ffvcom = '../input/gom5_grid.nc';
dataset = 'mwra';

Smax = 37;
Smin = 0;
Tmax = 30;
Tmin = 0;


% Read the GOM5 grid
f = f_load_grid(ffvcom, 'Coordinate', 'Geo');

% Read the TS data
irec = 0;
for i = 1 : length(fin)
    % HYDRO_NUTRIENTS
    table = readtable(fin(i), 'sheet', 'HYDRO_NUTRIENTS');   
    for j = 1 : height(table)
        irec = irec + 1;
        % longitude
        data0(irec).lon = table{j,9};
        % latitude
        data0(irec).lat = table{j,8};
        % depth
        data0(irec).depth = table{j,11};
        % time
        yyyy = num2str(table{j, 4}, '%4.4d');
        mm = num2str(table{j, 5}, '%2.2d');
        dd = num2str(table{j, 6}, '%2.2d');
        HHMM = table{j,7};
        data0(irec).time = datenum([yyyy mm dd HHMM{1}], 'yyyymmddHHMM');
        % T
        data0(irec).T = table{j,12};
        % S
        data0(irec).S = table{j,13};
    end

    % HYDRO_FLUORLIGHT
    table = readtable(fin(i), 'sheet', 'HYDRO_FLUORLIGHT');
    for j = 1 : height(table)
        irec = irec + 1;
        % longitude
        data0(irec).lon = table{j,9};
        % latitude
        data0(irec).lat = table{j,8};
        % depth
        data0(irec).depth = table{j,11};
        % time
        yyyy = num2str(table{j, 4}, '%4.4d');
        mm = num2str(table{j, 5}, '%2.2d');
        dd = num2str(table{j, 6}, '%2.2d');
        HHMM = table{j,7};
        data0(irec).time = datenum([yyyy mm dd HHMM{1}], 'yyyymmddHHMM');
        % T
        data0(irec).T = table{j,17};
        % S
        data0(irec).S = table{j,16};
    end
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






