%==========================================================================
% NECOFS TS Toolbox
%
% Remove the observation from structure 'obs'
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
function obs = obs_remove(obs, i, varargin)

varargin = read_varargin(varargin, {'iz'}, {[]});
varargin = read_varargin(varargin, {'it'}, {[]});
varargin = read_varargin2(varargin, {'All'});
varargin = read_varargin2(varargin, {'Temperature'});
varargin = read_varargin2(varargin, {'Salinity'});




if ~isempty(All)
    obs(i) = [];
else
    if ~isempty(iz)
        obs(i).depth(iz) = [];
        obs(i).T(iz, :) = [];
        obs(i).S(iz, :) = [];
        obs(i).nz = length(obs(i).depth(iz));
    end
    if ~isempty(it)
        obs(i).time(it) = [];
        obs(i).T(it, :) = [];
        obs(i).S(it, :) = [];
        obs(i).nt = length(obs(i).time(it));
    end
    if ~isempty(Temperature)
        obs(i).T = nan(obs(i).nz, obs(i).nt);
    end
    if ~isempty(Salinity)
        obs(i).S = nan(obs(i).nz, obs(i).nt);
    end
end