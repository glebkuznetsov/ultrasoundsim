% clc;
fprintf('================================[ KZK_spherical.m ]================================\n\n');
fprintf('This example calculates the transient pressure field of a spherical piston\n');
fprintf('using the KZK equation. The simulation may take three to five minutes to\n');
fprintf('complete depending on the speed of your computer. The script with plot\n');
fprintf('the pressure field versus time on the calculation grid.\n\n');

tic

% define a transducer structure/array
radius = 1e-2;
focus_distance = 10e-3;
Transducer=create_spherical_shell_planar_array(1, 1, radius, focus_distance ,.01,.01);
Transducer.amplitude = 2;


medium = set_medium('lossless');
medium.attenuationdBcmMHz = 0;
medium.nonlinearityparameter = 1;
% sampling frequency
fs=50e6;

% center frequency
f0=1e6;
omega = 2*pi*f0;
soundspeed = 1500; % m/s 

% define the calculation grid 
xmin = 0*radius;
xmax = 1.25*radius;
ymin = 0;
ymax = 0;
zmin = 0;
zmax = 2*focus_distance;

nx = 100;
ny = 1;
nz = 200;

dx = (xmax - xmin)/nx;
dz = (zmax - zmin)/nz;

x = xmin:dx:xmax;
z = zmin:dz:zmax;

coord_grid = set_coordinate_grid([dx 1 dz], xmin, xmax, ymin, ymax, zmin, zmax);
%set the input parameters: tone burst
%type 1 = tone burst, A0*sin(2.0*PI*f0*t)
%type 2 = hanning weighted pulse, A0*0.5*(1-cos(2*PI*f0*t/ncycles))*sin(2*PI*f0*t)
%order is [type f0 w B]
ncycles = 5;
input_func = set_excitation_function('tone burst', f0, ncycles/f0, 0);

% set begin and end retarded times 
taumin = -10*pi;
taumax = (14+ncycles)*2*pi;
tmin = taumin/omega;
tmax = taumax/omega + zmax/medium.soundspeed;
dt = 1/fs;

time_struct = set_time_samples(dt, tmin, tmax);

% set accuracy
pistonPts = 200;
RhoMax = 10;
dSigFD = 0.005;% 5e-3;

% control parameters
diflag = 1; %Diffraction
Knonlinearity = 1; %Nonlinearity constant
Kabsorption = 1; %Attenuation constant
FDmode = 1; %FDmode=1 IBFD, 0 CNFD

% Perform the calculation
tic();
[time, pkzk2] = kzk_transient(Transducer, coord_grid, medium, time_struct, input_func, diflag, FDmode, dSigFD, pistonPts, RhoMax);
t_kzk2 = toc();
fprintf('KZK finished in %f seconds\n', t_kzk2);

time_struct.tmax=time_struct.tmax - 24*pi/omega;
plot_transient_pressure(pkzk2, coord_grid, time_struct, 'xz', 'mesh');
