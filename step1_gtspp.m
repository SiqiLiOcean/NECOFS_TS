%==========================================================================
% NECOFS TS Toolbox
%
% Create NECOFS TS data
% Step 1 : read data into sturct format in dataset, month
%          --- GTSPP
%
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-06-15
%
%==========================================================================

clc
clear

%------Settings
indir = '../input/gtspp/';
outdir = '../output/step1/';
year = 2019;
ffvcom = '../input/gom5_grid.nc';
dataset = 'gtspp';

Smax = 37;
Smin = 0.1;
Tmax = 30;
Tmin = 0.1;


% Read the GOM5 grid
f = f_load_grid(ffvcom, 'Coordinate', 'Geo');

% Deal with the data every month
for im = 1 : 12

    disp(['----' num2str(year) num2str(im, '%2.2d')])

    fin = [indir 'at' num2str(year) num2str(im, '%2.2d')];
    

    data0 = read_gtspp(fin, 'Log');
    [data0.T] = data0.('TEMP');
    [data0.S] = data0.('PSAL');
    % Remove the useless variables
    data0 = rmfield(data0, {'TEMP', 'PSAL'});


    %------------------------------------------------------
    % Step 1. Remove the obs out of domain.
    px = [f.bdy_x{:}];
    py = [f.bdy_y{:}];
    data1 = obs_set_domain(data0, px, py);

    %------------------------------------------------------
    % Step 2. Separate the data in month
%     t1 = datenum(year, im, 1);
%     t2 = datenum(year, im+1, 1);
%     data2 = obs_set_time(data1, '>=', t1, '<', t2);
    data2 = data1;

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

% figure
% hold on
% f_2d_boundary(f);
% plot([data.lon], [data.lat], 'k.')