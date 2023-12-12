%==========================================================================
% NECOFS TS Toolbox
%
% Set the data out of range ([min max]) to NaN
%
% input  :
%   obs --- obs struct (containing lon, lat, depth, time, and other variables)
% 
% output :
%   out --- output obs struct
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-06-30
%
% Updates:
%
%==========================================================================
function out = obs_set_minmax(obs, varargin)

i = 0;
n = length(varargin);

out = obs;
while i<n
    i = i + 1;
    varname = varargin{i};
    i = i + 1;
    varmin = varargin{i};
    i = i + 1;
    varmax = varargin{i};


    if ~contains(fieldnames(obs), varname)
        error([varname ' NOT exists'])
    end

    if varmin >= varmax
        error(['Min should be smaller than Max'])
    end

    for j = 1 : length(obs)
        k = obs(j).(varname)>varmax | obs(j).(varname)<varmin;
        out(j).(varname)(k) = nan;
    end

end


