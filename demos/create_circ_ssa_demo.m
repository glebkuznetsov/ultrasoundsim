% Example of being able to stimulate anywhere in 2D space with a cylindrical
% array of transducers.
%
% Derived from examples/example_3_cw_excitation_cylindrical.m

% Setup the transducer array.
width = 1e-3;
height = 5e-3;
elements_x = 64;
elements_y = 1;
kerf = 2e-2 * pi;
spacing = width + kerf;
r_curv = 6e-2;
% transducer_array = create_rect_csa(elements_x, elements_y, width, height,...
%         kerf, kerf, r_curv);
% transducer_array = create_rect_enclosed_csa(elements_x,elements_y,width,height,kerf,r_curv)

radius = 1e-3
nrow = 10;
ang_open = 1;
transducer_array = create_circ_ssa(radius, r_curv, nrow, ang_open);
figure();
draw_array(transducer_array);

% Set up the media. By default we'll use water.
define_media();

% Set stimulation frequency.
f0 = 4e6;
lambda = (water.soundspeed / f0);

% Set the focus target.
focus_x = 2e-2;
focus_y = 0;
focus_z = 1e-2; % 2e-2; % 1cm

% Set up the viewport and resolution.
xmin = -1.2 * r_curv;
xmax = 1.2 * r_curv;
ymin = 0;
ymax = 0;
zmin = -1.2 * r_curv;
zmax = 1.2 * r_curv;
xpoints = 400;
ypoints = 1;
zpoints = 300;
dx = (xmax-xmin)/xpoints;
dy = (ymax-ymin)/ypoints;
dz = (zmax-zmin)/zpoints;
x = xmin:dx:xmax;
y = ymin:dy:ymax;
z = zmin:dz:zmax;
delta = [dx dy dz];
coord_grid = set_coordinate_grid(delta, xmin, xmax, ymin, ymax, zmin, zmax);

% Calculate the focus.
disp(['Focusing array at (', num2str(focus_x), ', ', num2str(focus_y), ...
', ', num2str(focus_z), ')']);
transducer_array = find_single_focus_phase(transducer_array, focus_x, ...
focus_y, focus_z, water, f0, 200);

% Run the simulation to calculate the pressure field.
ndiv=3;
tic();
disp('Calculating pressure field...');
p_cw=cw_pressure(transducer_array, coord_grid, water, ndiv, f0);
disp(['Simulation complete in ', num2str(toc()), ' seconds.'])

% Plot the result.
figure();
h = pcolor(x*100,z*100,rot90(squeeze(abs(p_cw)),3));
set(h,'edgecolor','none');
title('Pressure Field at y = 0 cm');
xlabel('x (cm)');
ylabel('z (cm)');
