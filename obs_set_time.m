%==========================================================================
% NECOFS TS Toolbox
%
% Pick the data between time [t1 t2]
%
% input  :
%   obs --- obs struct (containing lon, lat, depth, time, and other variables)
% 
% output :
%   out --- output obs struct
%
% Siqi Li, Lu Wang, and Changsheng Chen
% 2022-06-30
%
% Updates:
%
%==========================================================================
function out = obs_set_time(obs, t1_symb, t1, t2_symb, t2, varargin)

nobs = length(obs);
varargin = read_varargin(varargin, {'VarList'}, {["T", "S"]});

out = obs([]);

irec = 0;
for i = 1 : nobs

    t = obs(i).time;
    cmd = ['k = t' t1_symb 't1 & t' t2_symb 't2;'];
    eval(cmd);
    if sum(k)>0
        irec = irec + 1;
        out(irec) = obs(i);
        out(irec).time(~k) = [];
        for j = 1 : length(VarList)
            out(irec).(VarList(j))(:,~k) = [];
        end
%         out(irec).lon = obs(i).lon;
%         out(irec).lat = obs(i).lat;
%         out(irec).depth = obs(i).depth;
%         out(irec).time = obs(i).time(k);
%         out(irec).T = obs(i).T(:,k);
%         out(irec).S = obs(i).S(:,k);
    end
end
        