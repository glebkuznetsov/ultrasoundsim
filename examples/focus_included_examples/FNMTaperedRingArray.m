clc;
fprintf('===========================[ FNMTaperedRingArray.m ]===========================\n\n');
fprintf('This example calculates the continuous-wave pressure for an array of concentric\n');
fprintf('planar ring transducers excited at 2 MHz in a lossless medium. The width of\n');
fprintf('each ring is determined such that all elements have the same area.\n\n');

medium = set_medium('lossless');

f0 = 2e6; % excitation frequency
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

% define the computational grid
xmin = -1.5 * d/2;
xmax = 1.5 * d/2;
ymin = 0;
ymax = 0;
zmin = 0.0;
zmax = 4*d;
nx = 100;
nz = 200;
dx = xmax / nx;
dz = zmax / nz;

x = xmin:dx:xmax;
z = zmin:dz:zmax;
coordinates = set_coordinate_grid([dx 0 dz],xmin,xmax,ymin,ymax,zmin,zmax);

transducer = set_phases(transducer, 0, 0, zmax/2, medium, f0);

% generate the reference pressure field
ndiv = 100;
tic
pref = cw_pressure(transducer, coordinates, medium, ndiv, f0);
toc

figure(1);
draw_array(transducer);

% show the pressure field
figure(2);
pcolor(z*1000, x*1000, abs(squeeze(pref))/max(max(abs(squeeze(pref)))));
shading flat;
xlabel('axial distance (mm)');
ylabel('radial distance (mm)');
zlabel('normalized pressure');
