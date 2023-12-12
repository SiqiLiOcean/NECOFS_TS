%==========================================================================
% NECOFS TS Toolbox
%
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-03-02
%
% Updates:
%
%==========================================================================
function var2 = func_vertical_interp(z1, var1, z2, Window_z)


z1 = z1(:);
z2 = z2(:);
var1 = var1(:);

[iz, dz] = knnsearch(z1, z2);

k = find(dz<=Window_z);

var2 = nan * z2;
var2(k) = var1(iz(k));

