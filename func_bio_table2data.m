%==========================================================================
% NECOFS TS Toolbox
%
% Convert BIO data from table to MATLAB struct
% input  :
%   table
%   flag
% 
% output :
%   data
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-03-02
%
% Updates:
%
%==========================================================================
function data = func_bio_table2data(table, flag)

i = 1;
while  ~isempty(table.NAME{i}) 
    % lon
    data(i).lon = table.HEADER_START_LON(i);
    % lat
    data(i).lat = table.HEADER_START_LAT(i);
    % depth
    data(i).depth = table.HEADER_START_DEPTH(i);
    % time
    time1 = datestr(table.HEADER_START(i), 'yyyymmdd');
    time2 = num2str(table.HEADER_START_TIME(i), '%4.4d');
    data(i).time = datenum([time1 time2], 'yyyymmddHHMM');
    % var
    switch flag
        case 1
            data(i).T = table{i, end};
        case 2
            data(i).S = table{i, end};
        otherwise
            error('Unknown flag')
    end
    
    i = i + 1;
    if i > height(table)
        break
    end
end


