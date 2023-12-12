%==========================================================================
% NECOFS TS Toolbox
%
% Convert ocean pressure(P) to ocean depth(Z)
% (Depth-pressure relationships in the oceans and seas, Claude C. Leroy, 1997)
% input  :
%   P --- pressure (hPa)
%   lat --- latitude (optional, degree)
% 
% output :
%   Z --- depth
%
% Siqi Li, Lu Wang, and Changsheng Chen
% SMAST
% 2022-03-02
%
% Updates:
%
%==========================================================================
function Z = calc_p2z(P, lat)

if exist('lat', 'var')
    if length(lat(:)) == 1
        lat = lat * ones(size(P));
    end

    g = 9.780318 * (1 + 5.2788e-3*sind(lat).^2  - 2.36e-5*sind(lat).^4);
else
    g = 9.81;
end

% Convert P unit from hPa/mb to MPa
P = P / 1e4;

Z = (9.72659e2*P - 2.512e-1*P^2 + 2.279e-4*P^3 -1.82e-7*P^4) ./ ...
    (g + 1.092e-4*P);

end

