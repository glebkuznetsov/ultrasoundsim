clc;
clear;
fprintf('==============================[ KZK_spherical_cw.m ]===============================\n\n');
fprintf('This example calculates the cw pressure field of a spherical piston\n');
fprintf('using the KZK equation. The simulation may take about one minute to\n');
fprintf('complete depending on the speed of your computer. The script will mesh\n');
fprintf('the pressure on the calculation grid.\n\n');

% define a transducer structure/array
radius = 0.01;% 7.5e-3;
focus_distance = 60e-3;%18e-3;%60e-3;%90e-3; %8*7.5e-3;%8*7.5e-3;%60e-3;%29.5e-3;
Transducer=create_spherical_shell_planar_array(1, 1, radius, focus_distance ,.01,.01);
Transducer.amplitude = 3;

medium = set_medium('lossless');
medium.attenuationdBcmMHz = 0.5;%.1;%7e-4*689.0284;%1;
medium.nonlinearityparameter = 3.5;%2;%0.3290*8;%10;

% center frequency
f0 = 0.5e6;%1e6;
omega = 2*pi*f0;
soundspeed = 1500; % m/s 

% define the calculation grid 
xmin = 0*radius;%0;
xmax = 2*radius;%5*radius;
ymin = 0;
ymax = 0;
zmin = 0;
zmax = 100e-3;%focus_distance * 2;

nx = 200;
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
RhoMax = 10;
dSigFD = 0.00225;
NHARM = 10; % Number of Harmonics
Exflag = 0; % no effect

% Perform the calculation
tic();
pkzk_cw=kzk_cw(Transducer, coord_grid, medium, f0 , NHARM, dSigFD, pistonPts, RhoMax, Exflag);
t_kzk2 = toc();
fprintf('KZK finished in %f seconds\n', t_kzk2);

figure(1);
title('First Harmonic');
mesh(z,x,squeeze(abs(pkzk_cw(:,1,:,1))));
xlabel('axial distance (m)')
ylabel('radial distance (m)')
