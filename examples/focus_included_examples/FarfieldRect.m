clc;
fprintf('==========================[ FarfieldRect.m ]==========================\n\n');
fprintf('This script calculates the farfield continuous-wave pressure for an\n');
fprintf('array of rectangular transducers using the farfield_cw function. It\n');
fprintf('outputs the pressure profile of the array calculated with both\n');
fprintf('farfield_cw and fnm_cw and shows the difference between the two\n');
fprintf('methods. Note that the error is largest close to the nearfield region\n');
fprintf('and decreases as z approaches the Rayleigh Distance.\n\n');

% Transducer array
width = 3e-3;
height = 50e-3;
nelex = 128;
neley = 1;
kerf = 5e-4;
d = nelex * (width+kerf);
% Create array
xdcr_array = create_rect_planar_array(nelex, neley, width, height, kerf, 0);

% Use lossless medium
medium = set_medium('lossless');
% Center frequency and wavelength
f0 = 1e6;
lambda = medium.soundspeed/f0;

% Set up coordinate grid
xmin = -nelex*(width+kerf);
xmax = nelex*(width+kerf);
ymin = 0;
ymax = 0;
zmin = 10 * d;
zmax = (2*d^2)/lambda; % Rayleigh distance

xpoints = 130;
zpoints = 130;

dx = (xmax - xmin) / xpoints;
dz = (zmax - zmin) / zpoints;

x = xmin:dx:xmax;
z = zmin:dz:zmax;

cg = set_coordinate_grid([dx 0 dz], xmin, xmax, ymin, ymax, zmin, zmax);

% Perform calculation
ndiv = 15;
tic;
p_fnm = cw_pressure(xdcr_array, cg, medium, ndiv, f0);
t_fnm=toc();
fprintf('FNM calculation complete in %f s.\n', t_fnm);

tic;
p_farfield = farfield_cw(xdcr_array, cg, medium, ndiv, f0);
t_ff=toc();
fprintf('farfield_cw calculation complete in %f s.\n', t_ff);

% Plot results
% FNM pressure
figure(1);
pcolor(z, x*100, abs(squeeze(p_fnm(:,1,:))));
title('FNM pressure');
shading flat;
xlabel('z (m)');
ylabel('x (cm)');

% farfield_cw pressure
figure(2);
pcolor(z, x*100, abs(squeeze(p_farfield(:,1,:))));
title('farfield\_cw Pressure');
shading flat;
xlabel('z (m)');
ylabel('x (cm)');

% Calculate the error and plot it
figure(3);
p_err = abs((abs(p_fnm) - abs(p_farfield)) ./ (abs(p_fnm)));
mesh(z, x*100, squeeze(p_err(:,1,:)));
colormap(summer);
title('Normalized Error');
xlabel('z (m)');
ylabel('x (cm)');
zlabel('error');

max_error = max(max(max(p_err)));
fprintf('\nError at max pressure: %e\n', max_error);
fprintf('farfield_cw is about %i times as fast as fnm_cw.\n', ceil(t_fnm / t_ff));