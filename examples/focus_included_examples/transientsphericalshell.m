clc;
fprintf('==========================[ transientsphericalshell.m ]==========================\n\n');
fprintf('This example calculates the transient pressure field of a spherical shell using a\n');
fprintf('transient version of the Fast Nearfield Method. It outputs an animation of the\n');
fprintf('pressure through time.\n\n');

lossless = set_medium('lossless');
f0 = 1e6;
ncycles = 3;
lambda = lossless.soundspeed / f0;
omega = 2 * pi * f0;
k = 2 * pi / lambda;

% Define transducer size based on center frequency
R = 5 * sqrt(2) * lambda;
a = 5 * lambda;
d = sqrt(R^2 - a^2);
phi0 = asin(a/R);

xdcr = get_spherical_shell(a,R);

% Coordinate grid parameters
xmin = -1.5*d/2;
xmax = 1.5*d/2;
ymin = 0;
ymax = 0;
zmin = 0;
zmax = 2*d;

nx = 150;
nz = 300;

dx = (xmax - xmin)/nx;
dz = (zmax - zmin)/nz;

delta = [dx 0 dz];

x = xmin:dx:xmax;
z = zmin:dz:zmax;

fs = 16e6;
deltat = 1/fs;

% Define the coordinate grid
coord_grid = set_coordinate_grid(delta, xmin, xmax, ymin, ymax, zmin, zmax);

% Calculate begin and end times
[tmin, tmax] = impulse_begin_and_end_times(xdcr, coord_grid, lossless);
% Add excitation function duration to the end time
tmax = tmax + ncycles/f0;

t = tmin:deltat:tmax;

%set the excitation function
input_func = set_excitation_function('tone burst', f0, ncycles/f0, 0);

time_struct = set_time_samples(deltat, tmin, tmax);

ndiv = 20;
% Calculate the pressure
tic
pressure = transient_pressure(xdcr, coord_grid, lossless, time_struct, ndiv, input_func, 'fnm');
toc

plot_transient_pressure(pressure, coord_grid, time_struct, 'xz', 'mesh');
