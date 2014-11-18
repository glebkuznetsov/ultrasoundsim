clc;
fprintf('================================[ fdtsdcirc.m ]================================\n\n');
fprintf('This example calculates the transient pressure field of a circular piston using\n');
fprintf('the Fast Nearfield Method with Frequency Domain Time-Space decomposition. It\n');
fprintf('outputs an animation of the pressure through time. The excitation function used\n');
fprintf('in this example is the same as the one used in the tsdcirc example to enable\n');
fprintf('comparison between the two methods.\n\n');
tic
% Set up transducer
radius = 7.5e-3;
d = radius*2;
xdcr = get_circ(radius);

% Use lossless medium
lossless = set_medium('lossless');
%sampling frequency 10 MHz
fs=10e6;

% center frequency 1MHz
f0=1e6;
ncycles = 3;
deltat = 1/fs;
lambda = lossless.soundspeed / f0;

%define the calculation grid
xmin = -1.5*d/2;
xmax = 1.5*d/2;
ymin = 0;
ymax = 0;
zmin = 0;
zmax = d;

nx = 100;
nz = 200;

dx = (xmax - xmin)/nx;
dz = (zmax - zmin)/nz;

x = xmin:dx:xmax;
z = zmin:dz:zmax;
coord_grid = set_coordinate_grid([dx 0 dz], xmin, xmax, ymin, ymax, zmin, zmax);

%set accuracy
ndiv=20;

% Calculate begin and end times
[tmin, tmax] = impulse_begin_and_end_times(xdcr, coord_grid, lossless);
tmax = tmax + ncycles/f0;

t = tmin:deltat:tmax;

% Create a tone burst and sample it to use with FDTSD
signal = get_excitation_function('tone burst', f0, ncycles/f0, 0, deltat);
input_func = set_excitation_function(signal, deltat, 5e-2);

time_struct = set_time_samples(deltat, tmin, tmax);

% Calculate pressure
ptsd = transient_pressure(xdcr, coord_grid, lossless, time_struct, ndiv, input_func);

toc
plot_transient_pressure(ptsd, coord_grid, time_struct, 'xz', 'mesh');
