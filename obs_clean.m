%==========================================================================
% NECOFS TS Toolbox
%
% Remove the row/colum with no data
%
% input  :
%   obs --- obs struct (containing lon, lat, depth, time, and other variables)
% 
% output :
%   out --- output obs struct
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-06-17
%
% Updates:
%
%==========================================================================
function out = obs_clean(obs, varlist, varargin)


if ischar(varlist)
    varlist = convertCharsToStrings(varlist);
end

out = obs;
for i = 1 : length(obs)

    cmd_var = ['obs(i).' varlist{1}];
    for j = 2 : length(varlist)
        cmd_var = [cmd_var ', obs(i).' varlist{j}];
    end
    cmd = ['[id_keep, id_remove] = data_clean(' cmd_var ');'];
    eval(cmd)


    out(i).depth = obs(i).depth(id_keep{1});
    out(i).time = obs(i).time(id_keep{2});
    for j = 1 : length(varlist)
        tmp = obs(i).(varlist{j});
        tmp(id_remove{1},:) = [];
        tmp(:,id_remove{2}) = [];
        out(i).(varlist{j}) = tmp;
    end


end

for i = length(out) : -1 : 1
    if isempty(out(i).depth) || isempty(out(i).time)
    	out(i) = [];
    end
end

