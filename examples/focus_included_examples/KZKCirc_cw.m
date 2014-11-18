clc;
clear;
fprintf('==============================[ KZKCirc_cw.m ]==============================\n\n');
fprintf('This example calculates the CW pressure field of a circular piston\n');
fprintf('using the KZK equation. The simulation may take about one minute to\n');
fprintf('complete depending on the speed of your computer. The script will mesh\n');
fprintf('the pressure on the calculation grid.\n\n');

% define a transducer structure/array
radius = 0.01;%7.5e-3;
Transducer=create_circ_planar_array(1, 1, radius, .01,.01);
Transducer.amplitude = 3;

medium = set_medium('lossless');
medium.attenuationdBcmMHz = 0.5;% 0.1178*2;%1; /* A = delta * w0^3 * radius^2 / 4 / soundspeed^3 */
medium.nonlinearityparameter =  3.5;%1;%25*Transducer.amplitude*(2*pi*0.2e6)^2*radius^2/2/1500^3;%0.1178*6;%10; /* N = beta*Transducer.amplitude*w0^2*radius^2/2/soundspeed^3 */

% center frequency
f0=0.2e6;%1e6;%1e6;
omega = 2*pi*f0;
soundspeed = 1500; % m/s 

% define the calculation grid 
xmin = 0;
xmax = 2*radius; %4*radius;
ymin = 0;
ymax = 0;
zmin = 0;
zmax = (2*pi*f0)*radius^2/2/soundspeed;%(2*pi*f0)*radius^2/2/soundspeed*1;

nx = 100;
ny = 1;
nz = 200;

dx = (xmax - xmin)/nx;
dz = (zmax - zmin)/nz;

x = xmin:dx:xmax;
y = 0;
z = zmin:dz:zmax;

coord_grid = set_coordinate_grid([dx 1 dz], xmin, xmax, ymin, ymax, zmin, zmax);

% set accuracy
pistonPts = 200;
RhoMax = 8; 
dSigFD =  0.00225;
NHARM = 10; % Number of Harmonics
Exflag = 1; % 0 for changed grid, 1 for original grid

% Perform the calculation
tic();
pkzk_cw=kzk_cw(Transducer, coord_grid, medium, f0, NHARM, dSigFD, pistonPts, RhoMax, Exflag);
t_kzk2 = toc();
fprintf('KZK finished in %f seconds\n', t_kzk2);tic;
figure();
mesh(z,x,squeeze(abs(pkzk_cw(:,1,:,1))));
xlabel('axial distance (m)')
ylabel('radial distance (m)')
