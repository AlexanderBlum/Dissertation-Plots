function [outputArg1,outputArg2] = bond_density_model
E = 6.22*10^-10; % C-C bond strength [ nJ ]

% using a large unit makes the 'unit area' very big
% which means there will be a large number of bonds in that area
% which gives much larger numbers for bond density
% and corresponding large numbers for cleavage energy

% d = 3.56*1e-10; % lattice distance (m)
% d = 3.56e-8;    % lattice distance (cm)
% d = 3.56*1e-4;  % lattice distance (um)
d = 3.56*1e-1;  % lattice distance (nm)

% formula for bonds broken per unit area at a given miller index
% this can also be thought of as bond density
% hkl = miller index as 1x3 vector
% d   = lattice distance
% units: bonds/area^2
n_hkl = @(hkl) 4*max(hkl)/d^2/norm(hkl);

% formula to translate miller indices into theta value wrt surface
% units = degrees
theta = @(hkl_ref, hkl) acosd(hkl_ref*hkl'/norm(hkl_ref)/norm(hkl));

hkl = [0 0 1;
       1 1 0;
       1 1 0.5;
       1 1 1;
       1 1 1.2;
       1 1 1.5;
       1 1 2;
       1 1 2.5;
       1 1 3;
       1 1 3.5;
       1 1 4;
       1 1 6;
       1 1 8;
       3 3 2;
       4 4 2;
       2 2 1;
       3 3 1;
       4 4 1];

% calculate theoretic curves for bond density, cleavage, and distance
n_broken = nan(1, size(hkl, 1));
cleavage_energy = nan(1, size(hkl, 1));
theta_calc = nan(1, size(hkl, 1));
% find number of bonds broken (bond density), cleavage energy, and theta
% for each miller index
for ii = 1:size(hkl, 1)
    n_broken(ii) = n_hkl(hkl(ii,:));
    cleavage_energy(ii) = n_broken(ii)*E;
    theta_calc(ii) = theta(hkl(1,:), hkl(ii,:));
end   
end

