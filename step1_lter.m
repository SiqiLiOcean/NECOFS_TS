%==========================================================================
% NECOFS TS Toolbox
%
% Create NECOFS TS data
% Step 1 : read data into sturct format in dataset, month
%          --- LTER
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-06-30
%
%==========================================================================

clc
clear

%------Settings
indir = ["../input/lter/AR34A"
         "../input/lter/AR34B"
         "../input/lter/AR35-01"
         "../input/lter/AR35-02"
         "../input/lter/AR35-03"
         "../input/lter/AR35-05"
         "../input/lter/AR36"
         "../input/lter/AR38"
         "../input/lter/AR39a"
         "../input/lter/AR39b"
         "../input/lter/AR40"
         ];
outdir = '../output/step1/';
year = 2019;
ffvcom = '../input/gom5_grid.nc';
dataset = 'lter';

Smax = 37;
Smin = 0;
Tmax = 30;
Tmin = 0;


% Read the GOM5 grid
f = f_load_grid(ffvcom, 'Coordinate', 'Geo');

% Read the TS data
k = 0;
for i = 1 : length(indir)

    disp(['---' indir{i}])
    files = dir([indir{i} '/ctd/dar*']);

    for j = 1 : length(files)

        if endsWith(files(j).name, 'cnv')
            fin = [files(j).folder '/' files(j).name];
            disp(['     ' files(j).name])
            
            read_data = read_cnv(fin);
            
            k = k + 1;
            data0(k) = read_data;
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






