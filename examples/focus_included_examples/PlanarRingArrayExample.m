clc;
fprintf('===========================[ PlanarRingArrayExample.m ]===========================\n\n');
fprintf('This script uses the Fast Nearfield Method to calculate the pressure profile of a\n');
fprintf('seven-element array of 1 mm wide planar ring transducers. The script produces two\n');
fprintf('plots: the pressure and a diagram of the transducer array.\n\n');
% Set up the array
ring_count = 7;
ring_width = 5e-3;
kerf = 1e-3;

d = ring_count * 2 * (ring_width + kerf);

xdcr_array = create_concentric_ring_array(ring_count, ring_width, kerf);

% Set up the medium
medium = set_medium('lossless');
f0 = 1e6;
lambda = medium.soundspeed/f0;

% Set up the coordinate grid
xmin = -1.5 * d/2;
xmax = -xmin;
ymin = 0;
ymax = 0;
zmin = 0;
zmax = 2*d; % Beginning of Fresnel region

nx = 350;
ny = 1;
nz = 500;

dx = (xmax-xmin)/nx;
dy = (ymax-ymin)/ny;
dz = (zmax-zmin)/nz;

x = xmin:dx:xmax;
y = ymin:dy:ymax;
z = zmin:dz:zmax;

cg = set_coordinate_grid([dx dy dz], xmin, xmax, ymin, ymax, zmin, zmax);

% Focus the array
xdcr_array = set_phases(xdcr_array, 0, 0, zmax/2, medium, f0);

ndiv = 30;

% Calculate pressure
fprintf('Calculating pressure with FNM... ');
tic();
p = cw_pressure(xdcr_array, cg, medium, ndiv, f0);
fprintf('done in %f s.\n', toc());

% Draw the array
figure(1);
draw_array(xdcr_array);

% Plot the pressure
figure(2);
pcolor(z*1000, x*1000, squeeze(abs(p(:,1,:))));
xlabel('z (mm)');
ylabel('x (mm)');
title('Pressure at y = 0');
shading flat;