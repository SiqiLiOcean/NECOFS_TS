%==========================================================================
% NECOFS TS Toolbox
%
% Create a new obs struct 
%
% input  :
%   lon
%   lat
%   depth
%   time
%   varname1, var1, varname2, var2, ...
% 
% output :
%   obs --- obs struct (containing lon, lat, depth, time, and other variables)
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-06-17
%
% Updates:
%
%==========================================================================
function obs = obs_create(lon, lat, depth, time, varargin)

i = 0;
k = 0;
while i < length(varargin)
    
    k = k + 1;
    varname{k} = varargin{i+1};
    var{k} = varargin{i+2};

    i = i + 2;

end



for i = 1 : length(lon)

    obs(i).lon = lon(i);
    obs(i).lat = lat(i);
    obs(i).depth = depth(i);
    obs(i).time = time(i);

    for j = 1 : length(varname)
        obs(i).(varname{j}) = var{j}(i);
    end
end


    