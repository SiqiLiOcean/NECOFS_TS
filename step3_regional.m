%==========================================================================
% NECOFS TS Toolbox
%
% Create NECOFS TS data
% Step 3 : Write all data into FVCOM T/S format
%          Quality control included.
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-10-24
%
%==========================================================================
addpath('~/tools/matFVCOM')
addpath('~/tools/matFigure')



clc
clear

year = 2019;
ffvcom = '../../restart/gom5_cold_restart_0001.nc';
indir = '../output/step1/';
outdir = '../output/step3_gom5/';
dataset = ["aoml_bigelow"
           "bio"
           "cioos"
           "dmf"
           "emolt"
           "gtspp"
           "mwra"
           "nefsc"
           "neracoos"
           "pioneer_array"
           "rutgers_glider"
           "smast_pingguo"
           "whoi_dennis"
           "lter"
           ];

f = f_load_grid(ffvcom, 'Coordinate', 'xy');
F = scatteredInterpolant(f.x, f.y, f.h);

for im = 1 : 12
    
    disp(['----' num2str(year) num2str(im, '%2.2d')])
    files = dir([indir '/*_' num2str(year) num2str(im, '%2.2d') '.mat']);
    
    obs{im} = [];
    for i = 1 : length(files)
        % Input file
        fin = [files(i).folder '/' files(i).name];

        % Load the data
        load(fin);
        for j = 1 : length(dataset)
            if contains(files(i).name, dataset(j))
                source = j;
                break
            end
        end
        
        % Convert (lon, lat) to (x, y)
        [x, y] = sp_proj(1802, 'forward', [data.lon], [data.lat], 'm');
        h = F(double(x), double(y));
        cell = f_find_cell(f, x, y, 'Extrap');

        for k = 1 : length(data)
            data(k).source = source;
            data(k).x = x(k);
            data(k).y = y(k);  
            data(k).h = h(k);
            data(k).cell = cell(k);
        end

        obs{im} = [obs{im} data];
    end
    
    % Quality control.
    obs_qc{im} = ts_quality_control(obs{im});
end


% Write data out
for im = 1 : 12
    
    fxy = [outdir '/gom5_ts_' num2str(year) num2str(im, '%2.2d') '.xy'];
    fdat = [outdir '/gom5_ts_' num2str(year) num2str(im, '%2.2d') '.dat'];

    write_ts(obs_qc{im}, fxy, fdat);

end




% Plot
fgeo = f_load_grid(ffvcom, 'Coordinate', 'Geo');
[xlims, ylims] = f_2d_range(fgeo);
pos = mf_subpos(3, 4, 'ratio', diff(ylims)/diff(xlims), 'margin_bottom', 0.3);
% color = [226  31  38
%          246 153 153
%          41  95 138
%          95 152 198
%         175 203 227
%         114  59 122
%         173 113 181
%         214 184 218
%         245 126  32
%         253 191 110
%         236   0 140
%         247 153 209
%           0 174 239
%          96 200 232] / 255;
color = [  0 130 255;
         255 224  24;
         230  24  74;
          59 180  74;
         245 130  47;
         145  30 180;
          70 239 239;
         239  49 230;
         210 245  59;
         249 189 189;
           0 128 128;
         230 189 255;
         170 109  40;
         128   0   0;
         170 255 195;
         128 128   0;
         255 214 180;
           0   0 128;
         128 128 128;
         ]/255;
order = [6 8 1 2:5 7 9:14];
% order=1:14;
% close all
month = datestr(datenum(year,1:12,1), 'mmm');
close all
figure('Position', [  52           3        2257        1448])
for im = 1 : 12
    ax(im) = subplot('Position', pos(im,:));
    hold on
    f_2d_range(fgeo);
    f_2d_boundary(fgeo, 'Color', 'k');
    f_2d_coast(fgeo, 'Resolution', 'i')

    lon = [obs_qc{im}.lon];
    lat = [obs_qc{im}.lat];
    for i = order%1 : length(dataset)
        k = find([obs_qc{im}.source] == order(i));
        plot(lon(k), lat(k), 'o', ...
                    'MarkerFaceColor', color(i,:), ...
                    'MarkerEdgeColor', color(i,:), ...
                    'MarkerSize', 2.3);
    end
    if ismember(im, [10 11 12])
        xlabel('Longitude (^oW)')
    else
        set(gca, 'xticklabel', '')
    end
    if ismember(im, [1 4 7 10])
        ylabel('Latitude (^oN)')
    else
        set(gca, 'yticklabel', '')
    end
    mf_box(gca);
    mf_tick(gca);
    mf_label(gca, month(im,:), 'topleft')
    ht = text(-70, 40, {['Station #: ' num2str(length(obs_qc{im}))], ['Record #: ' num2str(sum([obs_qc{im}.nt]))]});
    ht.Position = [-69.10 33.86 0];
end
for i = order%1 : length(dataset)
    p(i) = plot(0, 0, 'o', ...
                    'MarkerFaceColor', color(i,:), ...
                    'MarkerEdgeColor', color(i,:), ...
                    'MarkerSize', 10);
end
hl = legend(p(:), upper(dataset(order)), 'NumColumns', 6, 'Interpreter', 'none');
hl.Position = [0.138 0.191 0.377 0.051];
title(ax(2), 'GOM5 Hindcast 2019 TS location')
% mf_save('gom5_ts_location_month.png')

