clc;
fprintf('============================[ Rayleightransientcirc.m ]============================\n\n');
fprintf('This example calculates the transient pressure field of a circular piston using a\n');
fprintf('transient version of the Rayleigh-Sommerfeld Integral. It outputs an animation of\n');
fprintf('the pressure through time.\n\n');

%demo file for FNM transient calculations with a circular piston.
radius = 7.5e-3;

%define a xdcr structure/array
xdcr = get_circ(radius);

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
%type 1 = tone burst, A0*sin(2.0*PI*f0*t)
%type 2 = hanning weighted pulse, .5*(1-cos(2*PI*t/w))*sin(2*PI*f0*t)
%type 3= t^3 pulse: A0*pow(t, 3)*exp(-B*t)*sin(2.0*PI*f0*t)
%order is [type A0 f0 w B]
input_func = set_excitation_function(1, 1, f0, ncycles/f0, 0);

time_struct = set_time_samples(deltat, tmin, tmax);

tic
pref = fnm_transient(xdcr, coord_grid, lossless, time_struct, ndiv, input_func, 0);
toc

nabscissas = 1:20; % beyond 20 RS just takes too long
times = zeros(size(ndiv));
errors = zeros(size(ndiv));
peakvalue = max(max(max(max(abs(pref)))));
for ndiv = 1:length(nabscissas),
    tic
    prs=rayleigh_transient(xdcr, coord_grid, lossless, time_struct, nabscissas(ndiv), input_func, 0);
    times(ndiv) = toc;
    errors(ndiv) = max(max(max(max(abs(pref - prs)))))/peakvalue;
end

figure(1)
plot(nabscissas, times)
ylabel('time (s)')
xlabel('number of abscissas')

figure(2)
semilogy(nabscissas, errors)
xlabel('number of abscissas')
ylabel('normalized error')

figure(3)
semilogy(times, errors)
xlabel('time (s)')
ylabel('normalized error')