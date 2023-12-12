%==========================================================================
% NECOFS TS Toolbox
%
% Calculate the mean var of the same location, same depth, same time
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
function out = obs_mean_var(obs, varargin)

varargin = read_varargin(varargin, {'List'}, {["T", "S"]});


llzt = [obs.lon; obs.lat; obs.depth; obs.time]';

unique_llzt = unique(llzt, 'rows');


for i = 1 : size(unique_llzt, 1)

    out(i).lon = unique_llzt(i, 1);
    out(i).lat = unique_llzt(i, 2);
    out(i).depth = unique_llzt(i, 3);
    out(i).time = unique_llzt(i, 4);
    
    [~, k] = ismember(unique_llzt(i,:), llzt, 'rows');

    for j = 1 : length(List)
        out(i).(List{j}) = mean([obs(k).(List{j})]);
    end
end