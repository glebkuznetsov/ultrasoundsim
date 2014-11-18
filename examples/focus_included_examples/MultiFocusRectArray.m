clc;
fprintf('==========================[ MultiFocusRectArray.m ]==========================\n\n');
fprintf('This script calculates the continuous-wave pressure for an array of an array\n');
fprintf('of rectangular transducers focused at five points. It outputs the pressure\n');
fprintf('profile of the array and a figure showing the array geometry.\n\n');

tic
% demo file for the multiple focus array simulation
% constant parameters
f0 = 1e6; % excitation frequency,Hz
soundspeed = 1500; % m/s
lambda = soundspeed / f0; % wavelength, m
width = 3e-3; % transducer width, m
height = 50e-3; % transducer height, m

%define a transducer structure/array
nelex = 128;
neley = 1;
kerf = 5.0e-4;
d = nelex*(width + kerf);

xdcr_array = create_rect_planar_array(nelex, neley, width, height, kerf, 0, [0 0 0]);

% create the data structure that specifies the attenuation value, etc.
lossless = set_medium('lossless');

% define the computational grid
xmin = -1.5 * d/2;
xmax = 1.5 * d/2;
ymin = 0;
ymax = 0;
zmin = 0.0;
zmax = 2*d;

nx = 160;
ny = 1;
nz = 250;

dx = (xmax-xmin) / nx;
dz = (zmax-zmin) / nz;

x = xmin:dx:xmax;
z = zmin:dz:zmax;

ps = set_coordinate_grid([dx 0 dz],xmin,xmax,ymin,ymax,zmin,zmax);

xmtx = [-d/3 -d/6 0 d/6 d/3];
ymtx = [0 0 0 0 0];
zmtx = [d d d d d];

% calculate the phase for the focus
xdcr_array = set_phases(xdcr_array,xmtx,ymtx,zmtx,lossless,f0,50);

% generate the reference pressure field
ndiv = 15;
tic
pref=cw_pressure(xdcr_array,ps,lossless,ndiv,f0,'fnm sse');
toc

figure(1);
draw_array(xdcr_array);

figure(2);
pcolor(z*1000, x*1000, abs(squeeze(pref)));
shading flat;
title('Pressure at y = 0');
xlabel('z (mm)');
ylabel('x (mm)');