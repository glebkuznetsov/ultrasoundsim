clc;
fprintf('===================================[ tsdrect.m ]===================================\n\n');
fprintf('This example calculates the transient pressure field of a rectangular piston using\n');
fprintf('the Fast Nearfield Method with Time-Space decomposition. It outputs an animation\n');
fprintf('of the pressure through time.\n\n');

width = 15e-3;
height = 15e-3;
d = width;

xdcr = get_rect(width, height);

f0=1e6;
ncycles = 3;

lossless = set_medium('lossless');
lambda = lossless.soundspeed/f0;

% Coordinate grid parameters
xmin = -1.5*d/2;
xmax = 1.5*d/2;
ymin = 0;
ymax = 0;
zmin = 0;
zmax = d;

nx = 130;
nz = 250;

dx = (xmax - xmin)/nx;
dz = (zmax - zmin)/nz;

fs = 10e6;
deltat = 1/fs;

x = xmin:dx:xmax;
z = zmin:dz:zmax;


% Define the coordinate grid
coord_grid=set_coordinate_grid([dx 1 dz],xmin,xmax,ymin,ymax,zmin,zmax);

% Calculate begin and end times
[tmin, tmax] = impulse_begin_and_end_times(xdcr, coord_grid, lossless);
% Add excitation function duration to the end time
tmax = tmax + ncycles/f0;

t = tmin:deltat:tmax;

%set accuracy
ndiv=20;
%set the excitation function
input_func = set_excitation_function('tone burst', f0, ncycles/f0, 0);

time_struct = set_time_samples(deltat, tmin, tmax);

% Calculate the pressure
tic
pressure = transient_pressure(xdcr, coord_grid, lossless, time_struct, ndiv, input_func);
toc

plot_transient_pressure(pressure, coord_grid, time_struct, 'xz', 'mesh');
