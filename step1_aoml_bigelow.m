%==========================================================================
% NECOFS TS Toolbox
%
% Create NECOFS TS data
% Step 1 : read data into sturct format in dataset, month
%          --- AOML_Biglow
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-06-30
%
%==========================================================================

clc
clear

%------Settings
indir = '../input/aoml_bigelow';
outdir = '../output/step1/';
year = 2019;
ffvcom = '../input/gom5_grid.nc';
dataset = 'aoml_bigelow';

Smax = 37;
Smin = 0;
Tmax = 30;
Tmin = 0;


% Read the GOM5 grid
f = f_load_grid(ffvcom, 'Coordinate', 'Geo');

% Read the TS data
file = dir([indir '/*.csv']);
irec = 0;
for i = 1 : length(file)
    fin = [indir '/' file(i).name];
    if endsWith(fin, 'csv')
        disp(file(i).name)

        table0 = readtable(fin);

        for j = 1 : height(table0)
            irec = irec + 1;
            % Longitude
            data0(irec).lon = table0.LONG_dec_degree(j);
            % Latitude
            data0(irec).lat = table0.LAT_dec_degree(j);
            % Time
            str = num2str(table0.DATE_UTC__ddmmyyyy(j), '%8.8d');
            num = time2num(table0.TIME_UTC_hh_mm_ss(j)) / 24;
            data0(irec).time = datenum(str, 'ddmmyyyy') + num;
            % Depth
            data0(irec).depth = 3;
            % T
            data0(irec).T = table0.TEMP_EQU_C(j);
            % S
            data0(irec).S = table0.SAL_permil(j);
        end
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






