clc;
fprintf('===========================[ TSDTaperedRingArray.m ]===========================\n\n');
fprintf('This example calculates the transient pressure field of an array of planar ring\n');
fprintf('transducers using the Fast Nearfield Method with Time-Space decomposition. The\n');
fprintf('width of each ring is determined such that all elements have the same area. The\n');
fprintf('script outputs an animation of the pressure in time and a diagram of the array.\n\n');
tic
%demo file for FNM transient.
%define a xdcr structure/array

f0 = 2e6; % excitation frequency
medium = set_medium('lossless');
soundspeed = medium.soundspeed; % m/s
lambda = soundspeed / f0; % wavelength
radius = lambda*5; % transducer radius
inner_area = pi * radius^2;
kerf = 3e-4;

% create the transducer object
el_count = 7;
inner_radii = zeros(1,el_count);
outer_radii = zeros(1,el_count);
for i = 1:el_count
    if i == 1
        inner_radii(i) = 0;
    else
        inner_radii(i) = outer_radii(i-1) + kerf;
    end
    outer_radii(i) = sqrt((inner_area + pi*inner_radii(i)^2)/pi); % Define outer radius so that elements have constant area
end
d = 2*outer_radii(el_count); % Array aperture

transducer = create_concentric_ring_array(el_count,inner_radii,outer_radii);

xdcr = create_concentric_ring_array(el_count,inner_radii,outer_radii);

%sampling frequency 10 MHz
fs=10e6;
deltat = 1/fs;

% center frequency 1MHz
f0=1e6;
ncycles = 3;

%define the calculation grid (simulating at a single point)
xmin = -1.5*d/2;
xmax = 1.5*d/2;
ymin = 0;
ymax = 0;
zmin = 0;
zmax = 1.1*d;

nx = 150;
nz = 300;

dx = (xmax-xmin)/nx;
dz = (zmax-zmin)/nz;

x = xmin:dx:xmax;
z = zmin:dz:zmax;

xdcr = set_time_delays(xdcr,0,0,d,medium,fs);

coord_grid = set_coordinate_grid([dx 0 dz], xmin, xmax, ymin, ymax, zmin, zmax);

%set accuracy
ndiv=20;

% Calculate begin and end times
[tmin, tmax] = impulse_begin_and_end_times(xdcr, coord_grid, medium);
tmin = 0;
% Add excitation function duration to end time
tmax = tmax + ncycles/f0;
t = tmin:deltat:tmax;

%set the excitation function
input_func = set_excitation_function('tone burst', f0, ncycles/f0, 0);

time_struct = set_time_samples(deltat, tmin, tmax);

%run the function!
pressure = transient_pressure(xdcr, coord_grid, medium, time_struct, ndiv, input_func);

fprintf('Simulation complete in %f s.\n', toc());

% show the result
figure(1);
draw_array(xdcr);

plot_transient_pressure(pressure, coord_grid, time_struct, 'xz', 'mesh');
