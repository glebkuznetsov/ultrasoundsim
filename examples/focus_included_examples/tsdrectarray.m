clc;
fprintf('===============================[ tsdrectarray.m ]===============================\n\n');
fprintf('This example calculates the transient pressure field of an array of rectangular\n');
fprintf('transducers using the Fast Nearfield Method with Time-Space decomposition. It\n');
fprintf('outputs an animation of the pressure through time.\n\n');

tic

% Define transducer array
width = 7e-4;
height = 15e-3;
nelex = 10;
neley = 1;
kerf = 0.5e-4;
d = nelex * (width+kerf);

xdcr_array = create_rect_planar_array(nelex, neley, width, height, kerf, 0);

f0 = 1e6;
ncycles = 3;

lossless = set_medium('lossless');
% Focus the array
xdcr_array = set_time_delays(xdcr_array, 0, 0, d, lossless);
lambda = lossless.soundspeed / f0;

% Calculation grid parameters
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

fs = 10e6;
deltat = 1/fs;

z = zmin:dz:zmax;
x = xmin:dx:xmax;

delta = [dx, 0, dz];


% Define the coordinate grid
coord_grid=set_coordinate_grid(delta, xmin, xmax, ymin, ymax, zmin, zmax);

xdcr_array = set_time_delays(xdcr_array, 0, 0, zmax/2, lossless);

% Calculate begin and end times
[tmin, tmax] = impulse_begin_and_end_times(xdcr_array, coord_grid, lossless);
% Add excitation function duration to the end time
tmax = tmax + ncycles/f0;

t = tmin:deltat:tmax;

%set the excitation function
input_func = set_excitation_function('tone burst', f0, ncycles/f0, 0);

time_struct = set_time_samples(deltat, tmin, tmax);

%set accuracy
ndiv=5;

% Calculate the pressure
pressure = transient_pressure(xdcr_array, coord_grid, lossless, time_struct, ndiv, input_func);

toc

plot_transient_pressure(pressure, coord_grid, time_struct, 'xz', 'mesh');
