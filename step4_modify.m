%==========================================================================
% NECOFS TS Toolbox
%
% Create GOM5 TS data
% Step 3 : Write all data into FVCOM (GOM5) T/S format
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
indir = '../output/step3_gom5/';
outdir = '../output/step4_final/';
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

%==========================================================================
% 2019-01
%==========================================================================
month = 1;
fxy = [indir '/gom5_ts_' num2str(year) num2str(month, '%2.2d') '.xy'];
fdat = [indir '/gom5_ts_' num2str(year) num2str(month, '%2.2d') '.dat'];
obs = read_ts(fxy, fdat);
%--------------------------------------------------------------------------
% Observations are partly modified:
% 0005 - remove the first two layers
obs = obs_remove(obs, 5, 'iz', 1:2);
% 0175 - remove the abnormol values
kt = find(obs(175).T>10);
ks = find(obs(175).S<30);
obs(175).T(kt) = nan;
obs(175).S(ks) = nan;
% 0207 - remove one salinity point
obs(207).S(1,1) = nan;
%--------------------------------------------------------------------------
% Temperature is removed:
obs = obs_remove(obs, 27, 'Temperature');
obs = obs_remove(obs, 168, 'Temperature');
%--------------------------------------------------------------------------
% Salinity is removed:
obs = obs_remove(obs, 206, 'Salinity');
obs = obs_remove(obs, 210, 'Salinity');
%--------------------------------------------------------------------------
% The whole station is remvoed:
obs = obs_remove(obs, 209, 'All');
obs = obs_remove(obs, 208, 'All');
obs = obs_remove(obs, 156, 'All');
%--------------------------------------------------------------------------
fxy_out = [outdir '/gom5_ts_' num2str(year) num2str(month, '%2.2d') '.xy'];
fdat_out = [outdir '/gom5_ts_' num2str(year) num2str(month, '%2.2d') '.dat'];
write_ts(obs, fxy_out, fdat_out);
clear obs

%==========================================================================
% 2019-02
%==========================================================================
month = 2;
fxy = [indir '/gom5_ts_' num2str(year) num2str(month, '%2.2d') '.xy'];
fdat = [indir '/gom5_ts_' num2str(year) num2str(month, '%2.2d') '.dat'];
obs = read_ts(fxy, fdat);
%--------------------------------------------------------------------------
% Observations are partly modified:

%--------------------------------------------------------------------------
% Temperature is removed:

%--------------------------------------------------------------------------
% Salinity is removed:

%--------------------------------------------------------------------------
% The whole station is remvoed:

%--------------------------------------------------------------------------
fxy_out = [outdir '/gom5_ts_' num2str(year) num2str(month, '%2.2d') '.xy'];
fdat_out = [outdir '/gom5_ts_' num2str(year) num2str(month, '%2.2d') '.dat'];
write_ts(obs, fxy_out, fdat_out);
clear obs

