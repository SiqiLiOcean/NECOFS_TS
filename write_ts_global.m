%==========================================================================
% NECOFS TS Toolbox
%
% Write FVCOM global TS data assimilation file.
%
% input  :
%   fout  --- output file
%   obs   --- obs struct
% 
% 
% output :
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-03-02
%
% Updates:
%
%==========================================================================
function write_ts_global(fout, obs, varargin)


varargin = read_varargin(varargin, {'Missing_value'}, {-999.0});
varargin = read_varargin(varargin, {'Out_t'}, {[]});
% varargin = read_varargin(varargin, {'Out_z'}, {[0:10:30 50:25:150 200:50:300 400:100:1400 1500:250:2000  2500:500:4000]});
varargin = read_varargin(varargin, {'Out_z'}, {[0:5:35 40:10:60 75:25:225 250:50:350 400:100:600 750 1000 1500 2000:1000:4000]});
varargin = read_varargin(varargin, {'Window_t'}, {10/60/24});
varargin = read_varargin(varargin, {'Window_z'}, {2.0});
varargin = read_varargin(varargin, {'Factor'}, {1.0});
varargin = read_varargin(varargin, {'Permission'}, {'w'});

% Out_z = [0:5:35 40:10:60 75:25:225 250:50:350 400:100:600 750 1000 1500 2000:1000:4000];
% % Out_t = datenum(2019,1,1) : 0.5/24 : datenum(2020,1,1)-0.001;
% Out_t = [];
% fout = 'test.dat';
% obs = data;
% Missing_value = -999.0;
% Factor = 1.0;

nz = length(Out_z);
fid = fopen(fout, Permission);

for i = 1 : length(obs)
    for it = 1 : length(obs(i).time)
        
        if isempty(Out_t)
            Out_timevec = datevec(obs(i).time(it));
        else
            dt = abs(Out_t-obs(i).time(it));

            if min(dt) > Window_t
                continue
            end
            kt = find(dt==min(dt));
            kt = kt(1);

            Out_timevec = datevec(Out_t(kt));
        end

        Out_hour = Out_timevec(4) + Out_timevec(5)/60 + Out_timevec(6)/3600;

        Out_T = func_vertical_interp(obs(i).depth, obs(i).T(:,it), Out_z, Window_z);
        Out_S = func_vertical_interp(obs(i).depth, obs(i).S(:,it), Out_z, Window_z);

        if all(isnan([Out_T;Out_S]))
            continue
        end

        Out_T(isnan(Out_T)) = Missing_value;
        Out_S(isnan(Out_S)) = Missing_value;

        if isfield(obs, 'dataset')
            fprintf(fid, '%12.6f %12.6f %6d %4d %4d %6.1f %4d %4.1f %30s\n', ...
                obs(i).lat, obs(i).lon, Out_timevec(1:3), Out_hour, nz, Factor, obs(i).dataset);
        else
            fprintf(fid, '%12.6f %12.6f %6d %4d %4d %6.1f %4d %4.1f\n', ...
                obs(i).lat, obs(i).lon, Out_timevec(1:3), Out_hour, nz, Factor);
        end
        for iz = 1 : nz
            fprintf(fid, '%10.1f %10.2f %10.2f\n', Out_z(iz), Out_T(iz), Out_S(iz));
        end

    end

end

fclose(fid);

