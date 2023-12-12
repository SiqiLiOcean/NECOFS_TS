%==========================================================================
% NECOFS TS Toolbox
%
% Join different obs struct according to (lon,lat,time)
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
function [z, t, var] = obs_merge_zt(z0, t0, var0, varargin)

varargin = read_varargin(varargin, {'z'}, {sort(unique(z0))});
varargin = read_varargin(varargin, {'t'}, {sort(unique(t0))});
varargin = read_varargin(varargin, {'z_window'}, {0.1});       % 0.1 m
varargin = read_varargin(varargin, {'t_window'}, {5/60/24});   % 5 min in day


% Convert the z into column and the t into row
z = z(:);
t = t(:);

% Dimensions
nz = length(z);
nt = length(t);

% -Adjust the z and t to the expected values (within the windows)
% -Remove the values that are far from the expected values
[kz, dz] = knnsearch(z, z0);
z1 = z(kz);
kz = dz<=z_window;

[kt, dt] = knnsearch(t, t0);
t1 = t(kt);
kt = dt<=t_window;

k = kz & kt;
z2 = z1(k);
t2 = t1(k);
var2 = var0(k);

% Get the obs var
[mesh_t, mesh_z] = meshgrid(t, z);
[kk, dd] = knnsearch([z2 t2], [mesh_z(:) mesh_t(:)]);

var = var2(kk);
var(dd>1e-3) = nan;
var = reshape(var, nz, nt);

t = t(:)';
