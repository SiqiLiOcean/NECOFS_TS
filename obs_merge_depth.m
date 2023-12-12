%==========================================================================
% NECOFS TS Toolbox
%
% Merge different obs depths of different variables
%
% input  :
%   z1, var1, z2, var2, ...
%     where z should be in column (nz0, 1), var should be in (nz0, nt0)
% 
% output :
%   z, var1, var2, ...
%     where z should be in column (nz, 1), var should be in (nz, nt0)
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-06-17
%
% Updates:
%
%==========================================================================
function [z, var] = obs_merge_depth(varargin)


i = 0;
k = 0;
z0_all = [];
while i < length(varargin)

    k = k + 1;
    z0{k} = varargin{i+1}(:);
    var0{k} = varargin{i+2};
    % Remove the nan
    id_nan = find(isnan(z0{k}));
    z0{k}(id_nan) = [];
    var0{k}(id_nan,:) = [];
    % Get the nt of every variable
    nt(k) = max([size(var0{k}, 2) 1]);
    % Combine all the z elements
    z0_all = [z0_all z0{k}'];

    
    i = i + 2;

end

% 
% z0{1} = [1 2 3 4 5]';
% z0{2} = [1 2 5 6 7]';
% z0{3} = [ 2 5 6 8]';
% z0{4} = []';
% z0{5} = []';



z = sort(unique(z0_all));
nz = length(z);



for i = 1 : length(z0)

    [~, id] = ismember(z0{i}, z);
    
    var{i} = nan(nz, nt(i));
    var{i}(id, :) = var0{i};

end