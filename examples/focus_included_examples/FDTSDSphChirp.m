clc;
fprintf('================================[ fdtsdcirc.m ]================================\n\n');
fprintf('This example calculates the transient pressure field of a circular piston using\n');
fprintf('the Fast Nearfield Method with Frequency Domain Time-Space decomposition. It\n');
fprintf('outputs an animation of the pressure through time. The transducer is excited\n');
fprintf('with a 1 MHz to 2 MHz linear chirp.\n\n');

% Set up transducer
radius = 7.5e-3;
d = radius*2;
xdcr = get_spherical_shell(radius, d);

% Use lossless medium
lossless = set_medium('lossless');
%sampling frequency 200 MHz
fs = 32e6;
deltat = 1/fs;

%define the calculation grid
xmin = -d/2;
xmax = d/2;
ymin = 0;
ymax = 0;
zmin = 0;
zmax = 2*d;

nx = 100;
ny = 1;
nz = 100;

dx = (xmax - xmin) / nx;
dy = (ymax - ymin) / ny;
dz = (zmax - zmin) / nz;

coord_grid = set_coordinate_grid([dx dy dz], xmin, xmax, ymin, ymax, zmin, zmax);

%set accuracy
ndiv=20;

% Create a tone burst and sample it to use with FDTSD
pulsewidth = 10 / 2e6;
signal = get_chirp(1e6,2e6,deltat,pulsewidth);
input_func = set_excitation_function(signal, deltat, 5e-2);

% Calculate begin and end times
[tmin, tmax] = impulse_begin_and_end_times(xdcr, coord_grid, lossless);
tmax = tmax+pulsewidth;

t = tmin:deltat:tmax;

time_struct = set_time_samples(deltat, tmin, tmax);

% Calculate pressure
tic();
ptsd = transient_pressure(xdcr, coord_grid, lossless, time_struct, ndiv, input_func);
toc

plot_transient_pressure(ptsd, coord_grid, time_struct, 'xz', 'mesh');
