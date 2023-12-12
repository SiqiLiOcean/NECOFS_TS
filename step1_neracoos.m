%==========================================================================
% NECOFS TS Toolbox
%
% Create NECOFS TS data
% Step 1 : read data into sturct format in dataset, month
%          --- NERACOOS
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-06-30
%
%==========================================================================

clc
clear


%------Settings
indir = '../input/neracoos';
dir_list = ["A01" "B01" "E01" "F01" "I01" "M01" "N01"];
outdir = '../output/step1/';
year = 2019;
ffvcom = '../input/gom5_grid.nc';
dataset = 'neracoos';

Smax = 37;
Smin = 0;
Tmax = 30;
Tmin = 0;


% Read the GOM5 grid
f = f_load_grid(ffvcom, 'Coordinate', 'Geo');

% Read the TS data
irec = 0;
for i = 1 : length(dir_list)
    files = dir([indir '/' dir_list{i} '/*.nc']);
    for j = 1 : length(files)
        fin = [files(j).folder '/' files(j).name];

        % Read the data
        read_lon = ncread(fin, 'lon');
        read_lat = ncread(fin, 'lat');
        read_depth = ncread(fin, 'depth');
        read_time = squeeze(ncread(fin, 'time') + datenum(1858, 11, 17));
        read_temperature = squeeze(ncread(fin, 'temperature'));
        read_salinity = squeeze(ncread(fin, 'salinity'));
        it = find(read_time>=datenum(year,1,1) & read_time<datenum(year+1,1,1));
        %
        if ~isempty(it)
            irec = irec + 1;
            data0(irec).lon = read_lon;
            data0(irec).lat = read_lat;
            data0(irec).depth = read_depth;
            data0(irec).time = read_time(it)';
            data0(irec).T = read_temperature(it)';
            data0(irec).S = read_salinity(it)';
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






