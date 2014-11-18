% clc;
fprintf('==============================[ KZKCirc.m ]==============================\n\n');
fprintf('This example calculates the transient pressure field of a circular piston\n');
fprintf('using the KZK equation. The simulation may take three to five minutes to\n');
fprintf('complete depending on the speed of your computer. The script will plot\n');
fprintf('the pressure field versus time on the calculation grid.\n\n');

tic

% define a transducer structure/array
radius = 0.01;%7.5e-3;
Transducer=create_circ_planar_array(1, 1, radius, .01,.01);
Transducer.amplitude = 3;

medium = set_medium('lossless');
medium.attenuationdBcmMHz = 0;% 0.1178*2;%1; /* A = delta * w0^3 * radius^2 / 4 / soundspeed^3 */
medium.nonlinearityparameter =  20;%25*Transducer.amplitude*(2*pi*0.2e6)^2*radius^2/2/1500^3;%0.1178*6;%10; /* N = beta*Transducer.amplitude*w0^2*radius^2/2/soundspeed^3 */
% sampling frequency
fs=20e6;%200e6;

% center frequency
f0=0.2e6;%1e6;
omega = 2*pi*f0;
soundspeed = 1500; % m/s 

% w0=2*pi*f0;
% numTauPtsPcy=fs/f0;

% define the calculation grid 
xmin = 0;
xmax = 1*radius;
ymin = 0;
ymax = 0;
zmin = 0;
zmax = (2*pi*f0)*radius^2/2/soundspeed*.3;%0.0419*0.3;%100e-3;

nx = 100;
nz = 200;

dx = (xmax - xmin)/nx;
dz = (zmax - zmin)/nz;

x = xmin:dx:xmax;
y = 0;
z = zmin:dz:zmax;

coord_grid = set_coordinate_grid([dx 1 dz], xmin, xmax, ymin, ymax, zmin, zmax);
%set the input parameters: tone burst
%type 1 = tone burst, A0*sin(2.0*PI*f0*t)
%type 2 = hanning weighted pulse, A0*0.5*(1-cos(2*PI*f0*t/ncycles))*sin(2*PI*f0*t)
%order is [type f0 w B]
ncycles = 5;
input_func = set_excitation_function(1, f0, ncycles/f0, 0);

% set begin and end retarded times 
taumin = -4*pi;
taumax = (14+ncycles)*2*pi;
tmin = taumin/omega;
tmax = taumax/omega + zmax/medium.soundspeed;
dt = 1/fs;

time_struct = set_time_samples(dt, tmin, tmax);

% set accuracy
pistonPts = 200;
RhoMax = 8; 
dSigFD =  1e-3;%5e-5;

% control parameters
diflag = 1; %Diffraction
Knonlinearity = 10; %Nonlinearity constant
Kabsorption = 1; %Attenuation constant
FDmode = 1; %FDmode=1 IBFD, 0 CNFD

% Perform the calculation
tic();
[time2, pkzk2] = kzk_transient(Transducer, coord_grid, medium, time_struct, input_func, diflag, FDmode, dSigFD, pistonPts, RhoMax);
t_kzk2 = toc();
fprintf('KZK finished in %f seconds\n', t_kzk2);

maxpressure = max(max(max(max(pkzk2))));
tpoints = size(pkzk2,3);

time_struct.tmax = time_struct.tmax - 4*pi / omega; 
plot_transient_pressure(pkzk2, coord_grid, time_struct, 'xz', 'mesh');
