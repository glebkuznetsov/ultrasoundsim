clc;
fprintf('===============================[ tsdmfrectarray.m ]===============================\n\n');
fprintf('This example calculates the transient pressure field of an array of rectangular\n');
fprintf('transducers using the Fast Nearfield Method with Time-Space decomposition. The\n');
fprintf('elements in this array have different excitation functions. The script will output\n');
fprintf('an animation of the pressure through time.\n\n');

tic
%demo file for FNM transient rect array
%define a transducer structure/array
width = 7e-4;
height = 15e-3;
nelex = 10;
neley = 1;
kerf = 0.5e-4;
d = nelex * (width+kerf);

xdcr_array = create_rect_planar_array(nelex, neley, width, height, kerf, 0);

f0=1e6;
df = 2.5e3;
ncycles = 3;

lossless = set_medium('lossless');

% Focus the array
xdcr_array = set_time_delays(xdcr_array, 0, 0, d, lossless);

lambda = lossless.soundspeed / (f0 + 4*df);

%define the calculation grid
xmin = -1.5*d/2;
xmax = 1.5*d/2;
ymin = 0;
ymax = 0;
zmin = 0;
zmax = d;

nx = 120;
nz = 250;

dx = (xmax - xmin)/nx;
dz = (zmax - zmin)/nz;

fs = 16e6;
deltat = 1/fs;

z = zmin:dz:zmax;
x = xmin:dx:xmax;

delta = [dx, 0, dz];

%define the calculation grid (simulating at a single point)
coord_grid=set_coordinate_grid(delta, xmin, xmax, ymin, ymax, zmin, zmax);

% Calculate begin and end times
[tmin, tmax] = impulse_begin_and_end_times(xdcr_array, coord_grid, lossless);
% Add excitation function duration to end time
tmax = tmax + ncycles/f0;

t = tmin:deltat:tmax;

%set the input parameters: tone burst
%type 1 = tone burst, A0*sin(2.0*PI*f0*t)
%type 2 = hanning weighted pulse, .5*(1-cos(2*PI*t/w))*sin(2*PI*f0*t)
%type 3= paper function, A0*pow(t, 3)*exp(-B*t)*sin(2.0*PI*f0*t)
%order is [type f0 w B]
excitations(1,:) = set_excitation_function(1, f0+4*df, ncycles/(f0+4*df), 0);
excitations(2,:) = set_excitation_function(1, f0+3*df, ncycles/(f0+3*df), 0);
excitations(3,:) = set_excitation_function(1, f0+2*df, ncycles/(f0+2*df), 0);
excitations(4,:) = set_excitation_function(1, f0+df, ncycles/(f0+df), 0);
excitations(5,:) = set_excitation_function(1, f0, ncycles/f0, 0);
excitations(6,:) = set_excitation_function(1, f0, ncycles/f0, 0);
excitations(7,:) = set_excitation_function(1, f0+df, ncycles/(f0+df), 0);
excitations(8,:) = set_excitation_function(1, f0+2*df, ncycles/(f0+2*df), 0);
excitations(9,:) = set_excitation_function(1, f0+3*df, ncycles/(f0+3*df), 0);
excitations(10,:) = set_excitation_function(1, f0+4*df, ncycles/(f0+4*df), 0);

time_struct = set_time_samples(deltat, tmin, tmax);

xdcr_array = set_apodization(xdcr_array, [0.3,0.4,0.5,0.75,1,1,0.75,0.5,0.4,0.3]);

%set accuracy
ndiv=5;

%run the function!
pressure = transient_pressure(xdcr_array, coord_grid, lossless, time_struct, ndiv, excitations);

toc

plot_transient_pressure(pressure, coord_grid, time_struct, 'xz', 'mesh');
