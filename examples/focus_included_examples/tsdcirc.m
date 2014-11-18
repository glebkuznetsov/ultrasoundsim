clc;
fprintf('=================================[ tsdcirc.m ]=================================\n\n');
fprintf('This example calculates the transient pressure field of a circular piston using\n');
fprintf('the Fast Nearfield Method with Time-Space decomposition. It outputs an animation\n');
fprintf('of the pressure through time.\n\n');

tic
%demo file for FNM transient.
%define a xdcr structure/array
radius = 7.5e-3;
d = radius * 2;

xdcr = get_circ(radius);

lossless = set_medium('lossless');
%sampling frequency 10 MHz
fs=10e6;

% center frequency 1MHz
f0=1e6;
ncycles = 3;
lambda = lossless.soundspeed/f0;

deltat = 1/fs;

%define the calculation grid
xmin = -1.5*d/2;
xmax = 1.5*d/2;
ymin = 0;
ymax = 0;
zmin = 0;
zmax = d;

nx = 150;
nz = 300;

dx = (xmax - xmin)/nx;
dz = (zmax - zmin)/nz;

x = xmin:dx:xmax;
z = zmin:dz:zmax;
coord_grid = set_coordinate_grid([dx 1 dz], xmin, xmax, ymin, ymax, zmin, zmax);

%set accuracy
ndiv=20;

% Calculate begin and end times
[tmin, tmax] = impulse_begin_and_end_times(xdcr, coord_grid, lossless);
% Add excitation function duration to end time
tmax = tmax + ncycles/f0;

t = tmin:deltat:tmax;

%set the excitation function
input_func = set_excitation_function('tone burst', f0, ncycles/f0, 0);

time_struct = set_time_samples(deltat, tmin, tmax);

%run the function!
pressure = transient_pressure(xdcr, coord_grid, lossless, time_struct, ndiv, input_func);

toc
% show the result
plot_transient_pressure(pressure, coord_grid, time_struct, 'xz', 'mesh');
