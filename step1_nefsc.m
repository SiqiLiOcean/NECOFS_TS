%==========================================================================
% NECOFS TS Toolbox
%
% Create NECOFS TS data
% Step 1 : read data into sturct format in dataset, month
%          --- NEFSC
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-06-30
%
%==========================================================================

clc
clear


%------Settings
fin = '../input/nefsc/casts_2019.mat';
outdir = '../output/step1/';
year = 2019;
ffvcom = '../input/gom5_grid.nc';
dataset = 'nefsc';

Smax = 37;
Smin = 0;
Tmax = 30;
Tmin = 0;


% Read the GOM5 grid
f = f_load_grid(ffvcom, 'Coordinate', 'Geo');

% Read the TS data
load(fin);
cmd = ['data0 = casts_' num2str(year) ';'];
eval(cmd);
cmd = ['clear casts_' num2str(year) ';'];
eval(cmd);
% Do some modifications to the data
for i = 1 : length(data0)
    % Calculate the time in datenum format
    data0(i).time = data0(i).dyd + datenum(data0(i).yr,1,1);
    % Add minus sign to longitude
    data0(i).lon = -data0(i).lon;
end
% Change the variable names
[data0.depth] = data0.p;
[data0.T] = data0.t;
[data0.S] = data0.s;
% Remove the useless variables
data0 = rmfield(data0, {'cast', 'yr', 'yd', 'pc', 'vn', 'p',...
                        'np', 'gear', 'cru', 'opsid', 'dyd', 't', 's'});





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






