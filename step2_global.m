%==========================================================================
% NECOFS TS Toolbox
%
% Create NECOFS TS data
% Step 2 : Write all data into Global-FVCOM T/S format
%          
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-06-30
%
%==========================================================================

clc
clear

year = 2019;
indir = '../output/step1/';
fout = ['../output/step2_global/global_gom_ts_' num2str(year) '.dat'];
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

% Delete the out file, if exist
if isfile(fout), delete(fout); end

for i = 1 : length(dataset)

    for im = 1 : 12
        
        % Input file
        fin = [indir dataset{i} '_' num2str(year) num2str(im, '%2.2d') '.mat'];
        
        % Check if the input file exists. If not, jump to the next one.
        if ~isfile(fin), continue; end

        disp(['---' dataset{i} '  ' num2str(year) ' ' num2str(im, '%2.2d')])

        % Read the data
        load(fin);
        % Add the dataset and the yyyymm information
        C = cell(1,length(data));
        C(:) = {[dataset{i} '_' num2str(year) num2str(im, '%2.2d')]};
        [data.dataset] = C{:};

        % Write the data into the output file
        write_ts_global(fout, data, 'Permission', 'a');

    end
end


