%demo file for FNM transient calculations with a circular piston.
clc;
fprintf('=============================[ FNMtransientcirc.m ]=============================\n\n');
fprintf('This example calculates the transient pressure for a circular transducer using\n');
fprintf('the Fast Nearfield Method. It will output a plot of the pressure, the error of\n');
fprintf('the calculation compared to the number of abscissas, the number of abscissas\n');
fprintf('compared to the execution time, and the error compared to the execution time.\n\n');
radius = 7.5e-3;

%define a transducer structure/array
Transducer=create_circ_planar_array(1, 1, radius, .01,.01);

lossless = set_medium('lossless');

%sampling frequency 10 MHz
fs=10e6;

% center frequency 1MHz
f0=1e6;
ncycles = 3;

tmin=0;
tmax=8 * 2.75e-6;
deltat = 1/fs;
t = tmin:deltat:tmax;

%define the calculation grid (simulating at a single point)
delta = [0.015e-3 * 18 0 0.018e-3];
xmin = -0.9e-3 * 18;
xmax = 0.9e-3 * 18;
ymin = 0;
ymax = 0;
zmin = 0;
zmax = 4 * 1.8e-3;

x = xmin:delta(1):xmax;
y = ymin:delta(2):ymax;
z = zmin:delta(3):zmax;

coord_grid=set_coordinate_grid(delta, xmin, xmax, ymin, ymax, zmin, zmax);

if (xmin == xmax),
    nx = 1;
else
    nx = length(x);
end
if (ymin == ymax),
    ny = 1;
else
    ny = length(y);
end
if (zmin == zmax),
    nz = 1;
else
    nz = length(z);
end

%set accuracy
ndiv=200;

%set the input parameters: tone burst
input_func = set_excitation_function('tone burst', f0, ncycles/f0, 0);


time_struct = set_time_samples(deltat, tmin, tmax);

disp('Calculating reference pressure...');
tic
pref = fnm_transient(Transducer, coord_grid, lossless, time_struct, ndiv, input_func, 0);
toc

maxndiv = 200;
times = zeros(1, maxndiv);
errors = zeros(1, maxndiv);
peakvalue = max(max(max(max(abs(pref)))));
for ndiv = 1:maxndiv
    fprintf('Calculating pressure for ndiv = %i / %i\n', ndiv, maxndiv);
    tic
    pfnm = fnm_transient(Transducer, coord_grid, lossless, time_struct, ndiv, input_func, 0);

    times(ndiv) = toc;
    errors(ndiv) = max(max(max(max(abs(pref - pfnm)))))/peakvalue;
end

figure(1)
plot(times)
ylabel('time (s)')
xlabel('number of abscissas')

figure(2)
semilogy(errors)
xlabel('number of abscissas')
ylabel('normalized error')

figure(3)
semilogy(times, errors)
xlabel('time (s)')
ylabel('normalized error')
