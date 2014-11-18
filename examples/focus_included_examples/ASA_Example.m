clc;
fprintf('=================================[ ASA_Example.m ]================================\n\n');
fprintf('This script calculates the 3D pressure of a 128-element array of rectangular\n');
fprintf('transducers by using the Angular Spectrum Approach to propagate an initial field\n');
fprintf('calculated with the Fast Nearfield Method. The script produces two plots:\n');
fprintf('the initial FNM pressure and the pressure at y = 0 as calculated with the ASA.\n\n');

% Set up the array
ele_x = 128;
ele_y = 1;
width = 0.245e-3;
height = 7e-3;
kerf_x = 0.03e-3;
kerf_y = 0;
d = ele_x * (width+kerf_x); % Array aperture
N = 2; % f-number
% Create planar array of rectangular transducers
xdcr_array = create_rect_planar_array(ele_x, ele_y, width, height, kerf_x, kerf_y);
% Use lossless medium
medium = set_medium('lossless');
% Center frequency and wavelength
f0 = 3e6;
lambda = medium.soundspeed/f0;

% Set the focus to be at the desired f-number
focus_x = 0;
focus_y = 0;
focus_z = d * N;

% Set up the coordinate grid
xmin = -((ele_x/2) * (width+kerf_x))*1.5;
xmax = -xmin;
ymin = -((ele_y/2) * (height+kerf_y))*1.5;
ymax = -ymin;
zmin = lambda/4;
zmax = focus_z*2;

dx = lambda/2;
dy = lambda/2;
dz = lambda/2;

x = xmin:dx:xmax;
y = ymin:dy:ymax;
z = zmin:dz:zmax;

% Determine where the source pressure will be calculated
z0 = lambda/4;
y_index = floor((ymax-ymin)/2/dy);
% Coordinate grids to calclate the initial pressure (x-y plane) and final
% pressure (x-z plane)
cg_p0 = set_coordinate_grid([dx dy 1], xmin,xmax,ymin,ymax,z0,z0);
cg_3d = set_coordinate_grid([dx dy dz],xmin,xmax,ymin,ymax,zmin,zmax);

% Focus the array
xdcr_array = set_phases(xdcr_array,focus_x,focus_y,focus_z,medium,f0,200);

% Calculate the pressure
ndiv = 10;
fprintf('Calculating initial pressure plane with FNM... ');
tic();
p0 = cw_pressure(xdcr_array,cg_p0,medium,ndiv,f0,'fnm sse');
fprintf('done in %f s.\n', toc());

fprintf('Calculating 3D pressure (%i points) with ASA... ', (length(x) * length(y) * length(z)));
tic();
p_asa = cw_angular_spectrum(p0,cg_3d,medium,f0,1024,'Pa');
fprintf('done in %f s.\n', toc());

% Show the initial pressure
figure(1);
pcolor(x*1000, y*1000, rot90(abs(squeeze(p0(:,:,1)))));
xlabel('x (mm)');
ylabel('y (mm)');
shading flat;
title(['p0 (Calculated with FNM at z = ', num2str(z0*1000), ' mm)']);
% Show the 3D field calculated with ASA
figure(2);
pcolor(z*1000, x*1000, abs(squeeze(p_asa(:,y_index,:))));
xlabel('z (mm)');
ylabel('x (mm)');
shading flat;
title('ASA Pressure (y=0)');
