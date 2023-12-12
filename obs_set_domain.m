%==========================================================================
% NECOFS TS Toolbox
%
% Pick the data in the domain polygon
%
% input  :
%   obs --- obs struct (containing lon, lat, depth, time, and other variables)
%   px  --- domain polygon x
%   py  --- domain polygon y
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
function out = obs_set_domain(obs, px, py)



nobs = length(obs);
out = obs([]);

lon = [obs(:).lon];
lat = [obs(:).lat];

loc_in = [lon(:) lat(:)];
loc_out = unique(loc_in, 'rows');
[~, k] = ismember(loc_in, loc_out, 'rows');

id1 = find(inpolygon(loc_out(:,1), loc_out(:,2), px, py));

id2 = ismember(k, id1);

out = obs(id2);
